#!/bin/bash

set -e

echo "========================================="
echo "Linux Bootstrap - Automated Server Setup"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/sswaner/linux-bootstrap.git"
BOOTSTRAP_DIR="$HOME/code/linux-bootstrap"

# Prompt for credentials if not set as environment variables
echo "Checking credentials..."
echo ""

# Function to read from terminal (works even when script is piped from curl)
read_from_terminal() {
    local prompt="$1"
    local var_name="$2"
    local is_secret="${3:-false}"

    if [ "$is_secret" = "true" ]; then
        read -s -p "$prompt" value < /dev/tty
        echo "" # New line after secret input
    else
        read -p "$prompt" value < /dev/tty
    fi

    echo "$value"
}

# Check/prompt for ANTHROPIC_API_KEY
if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo -e "${YELLOW}ANTHROPIC_API_KEY not found in environment${NC}"
    echo "Get your API key from: https://console.anthropic.com/"
    ANTHROPIC_API_KEY=$(read_from_terminal "Enter your Anthropic API key (starts with sk-ant-): " "ANTHROPIC_API_KEY" true)

    if [ -z "$ANTHROPIC_API_KEY" ]; then
        echo -e "${RED}Error: Anthropic API key is required${NC}"
        exit 1
    fi

    # Basic validation
    if [[ ! "$ANTHROPIC_API_KEY" =~ ^sk-ant- ]]; then
        echo -e "${YELLOW}Warning: API key doesn't start with 'sk-ant-'. Continuing anyway...${NC}"
    fi
    echo ""
else
    echo -e "${GREEN}✓ ANTHROPIC_API_KEY found${NC}"
fi

# Check/prompt for TAILSCALE_AUTH_KEY
if [ -z "$TAILSCALE_AUTH_KEY" ]; then
    echo -e "${YELLOW}TAILSCALE_AUTH_KEY not found in environment${NC}"
    echo "Generate an auth key at: https://login.tailscale.com/admin/settings/keys"
    echo "(Create a reusable key with appropriate expiration)"
    TAILSCALE_AUTH_KEY=$(read_from_terminal "Enter your Tailscale auth key (starts with tskey-auth-): " "TAILSCALE_AUTH_KEY" true)

    if [ -z "$TAILSCALE_AUTH_KEY" ]; then
        echo -e "${RED}Error: Tailscale auth key is required${NC}"
        exit 1
    fi

    # Basic validation
    if [[ ! "$TAILSCALE_AUTH_KEY" =~ ^tskey-auth- ]]; then
        echo -e "${YELLOW}Warning: Auth key doesn't start with 'tskey-auth-'. Continuing anyway...${NC}"
    fi
    echo ""
else
    echo -e "${GREEN}✓ TAILSCALE_AUTH_KEY found${NC}"
fi

# Check/prompt for OP_SERVICE_ACCOUNT_TOKEN (optional)
if [ -z "$OP_SERVICE_ACCOUNT_TOKEN" ]; then
    echo -e "${BLUE}OP_SERVICE_ACCOUNT_TOKEN not found (optional)${NC}"
    echo "Press Enter to skip, or paste your 1Password service account token:"
    OP_SERVICE_ACCOUNT_TOKEN=$(read_from_terminal "1Password service account token (optional, starts with ops_): " "OP_SERVICE_ACCOUNT_TOKEN" true)

    if [ -n "$OP_SERVICE_ACCOUNT_TOKEN" ]; then
        # Basic validation
        if [[ ! "$OP_SERVICE_ACCOUNT_TOKEN" =~ ^ops_ ]]; then
            echo -e "${YELLOW}Warning: Token doesn't start with 'ops_'. Continuing anyway...${NC}"
        fi
        echo -e "${GREEN}✓ 1Password service account token set${NC}"
    else
        echo "Skipping 1Password integration"
    fi
    echo ""
else
    echo -e "${GREEN}✓ OP_SERVICE_ACCOUNT_TOKEN found${NC}"
fi

echo -e "${GREEN}✓ All required credentials provided${NC}"
echo ""

# Check if running on supported OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo -e "${RED}Error: Cannot detect operating system${NC}"
    exit 1
fi

if [[ "$OS" != "ubuntu" && "$OS" != "debian" ]]; then
    echo -e "${YELLOW}Warning: This script is designed for Ubuntu/Debian.${NC}"
    echo -e "${YELLOW}Detected OS: $OS${NC}"
    echo "Proceeding anyway, but there may be issues..."
    echo ""
fi

# Check for required tools
echo "Checking prerequisites..."
MISSING_TOOLS=()

if ! command -v git &> /dev/null; then
    MISSING_TOOLS+=("git")
fi

if ! command -v curl &> /dev/null; then
    MISSING_TOOLS+=("curl")
fi

if [ ${#MISSING_TOOLS[@]} -ne 0 ]; then
    echo -e "${RED}Error: Missing required tools: ${MISSING_TOOLS[*]}${NC}"
    echo ""
    echo "Please install them first:"
    echo "  sudo apt update && sudo apt install -y ${MISSING_TOOLS[*]}"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓ Prerequisites satisfied${NC}"
echo ""

# Clone or update repository
if [ -d "$BOOTSTRAP_DIR/.git" ]; then
    echo "Repository already exists at $BOOTSTRAP_DIR"
    echo "Updating to latest version..."
    cd "$BOOTSTRAP_DIR"
    git pull origin main || echo -e "${YELLOW}Warning: Could not update repository${NC}"
else
    echo "Cloning bootstrap repository..."
    mkdir -p "$(dirname "$BOOTSTRAP_DIR")"
    git clone "$REPO_URL" "$BOOTSTRAP_DIR"
fi

echo -e "${GREEN}✓ Repository ready${NC}"
echo ""

# Install Claude Code CLI if not present
if command -v claude &> /dev/null; then
    CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "unknown")
    echo -e "${GREEN}✓ Claude Code is already installed${NC}"
    echo "  Version: $CLAUDE_VERSION"
    echo ""
else
    echo "Installing Claude Code CLI..."
    echo ""

    # Install using the official method from Anthropic docs
    # The installation downloads the latest binary
    curl -fsSL https://storage.googleapis.com/anthropic-cli/install.sh | sh

    # Add to PATH for current session
    export PATH="$HOME/.local/bin:$PATH"

    # Verify installation
    if command -v claude &> /dev/null; then
        echo -e "${GREEN}✓ Claude Code installed successfully${NC}"
        CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "unknown")
        echo "  Version: $CLAUDE_VERSION"
        echo ""
    else
        echo -e "${RED}Error: Claude Code installation failed${NC}"
        echo "Trying alternative installation method..."

        # Alternative: Install via npm if available
        if command -v npm &> /dev/null; then
            sudo npm install -g @anthropic-ai/claude-code
            if command -v claude &> /dev/null; then
                echo -e "${GREEN}✓ Claude Code installed via npm${NC}"
            else
                echo -e "${RED}Error: All installation methods failed${NC}"
                echo "Please install manually: https://docs.anthropic.com/claude-code"
                exit 1
            fi
        else
            echo -e "${RED}Error: Cannot install Claude Code${NC}"
            echo "Please install manually: https://docs.anthropic.com/claude-code"
            exit 1
        fi
    fi
fi

# Export environment variables for Claude Code session
export ANTHROPIC_API_KEY
export TAILSCALE_AUTH_KEY
export OP_SERVICE_ACCOUNT_TOKEN

# Run Claude Code with automated setup
echo "========================================="
echo "Starting Automated Setup"
echo "========================================="
echo ""
echo "Claude Code will now:"
echo "  • Update and patch the system"
echo "  • Join Tailscale VPN network"
echo "  • Install development tools (AWS CLI, GitHub CLI, 1Password CLI, Wrangler)"
echo "  • Install terminal tools (Zellij, Neovim)"
echo "  • Set up Python environments (3.14 and 3.13)"
echo "  • Configure dotfiles"
echo "  • Verify all installations"
echo ""
echo "This will run unattended. Check the output for any issues."
echo ""
echo -e "${YELLOW}Note: You may be prompted for sudo password during system updates.${NC}"
echo ""

# Change to bootstrap directory
cd "$BOOTSTRAP_DIR"

# Run Claude Code with the setup prompt
# Using --yes flag to auto-approve actions (if available)
# The prompt references CLAUDE.md which contains all setup instructions
claude code --api-key "$ANTHROPIC_API_KEY" <<'EOF'
Please follow the instructions in CLAUDE.md to set up this server.

Important notes:
- Use headless/non-interactive mode for all installations
- The TAILSCALE_AUTH_KEY environment variable is set for unattended Tailscale join
- The OP_SERVICE_ACCOUNT_TOKEN environment variable may be set for 1Password CLI
- Skip any interactive authentication steps that require manual user input
- Run all commands and verify successful completion
- If any step fails, log the error but continue with remaining steps

After completing all steps, provide a summary of:
- What was successfully installed
- What failed (if anything)
- Any manual steps still required
EOF

echo ""
echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo ""
echo "Your server is now configured and ready to use."
echo ""
echo "Next steps:"
echo "  • Verify Tailscale connection: ${GREEN}tailscale status${NC}"
echo "  • Reload shell for dotfiles: ${GREEN}exec \$SHELL${NC}"
echo "  • Check installed tools: ${GREEN}aws --version, gh --version, etc.${NC}"
echo ""
echo "Repository location: ${BLUE}$BOOTSTRAP_DIR${NC}"
echo ""
