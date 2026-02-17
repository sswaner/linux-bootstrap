#!/bin/bash

set -e

echo "======================================="
echo "Linux Bootstrap - Claude Code Installer"
echo "======================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

# Check if Claude Code is already installed
if command -v claude &> /dev/null; then
    CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "unknown")
    echo -e "${GREEN}✓ Claude Code is already installed${NC}"
    echo "  Version: $CLAUDE_VERSION"
    echo ""
    echo "Skipping installation (already present)."
    echo ""
else
    echo "Installing Claude Code CLI..."
    echo ""

    # Install Claude Code using official method
    # The official installation is via npm/homebrew, but for Linux servers
    # the most common method is via direct download or package manager
    # Using the official installer script if available

    if curl -fsSL https://api.claude.com/install.sh &> /dev/null; then
        # If official installer exists, use it
        curl -fsSL https://api.claude.com/install.sh | bash
    else
        # Fallback: Install via npm if available, or provide manual instructions
        if command -v npm &> /dev/null; then
            echo "Installing Claude Code via npm..."
            sudo npm install -g @anthropic-ai/claude-code
        else
            echo -e "${YELLOW}Note: Automated installation not available.${NC}"
            echo ""
            echo "Please install Claude Code manually:"
            echo "1. Visit: https://docs.anthropic.com/claude-code"
            echo "2. Follow installation instructions for your system"
            echo "3. Re-run this script to verify installation"
            echo ""
            exit 1
        fi
    fi

    # Verify installation
    if command -v claude &> /dev/null; then
        echo -e "${GREEN}✓ Claude Code installed successfully${NC}"
        CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "unknown")
        echo "  Version: $CLAUDE_VERSION"
        echo ""
    else
        echo -e "${RED}Error: Claude Code installation failed${NC}"
        echo "Please install manually: https://docs.anthropic.com/claude-code"
        exit 1
    fi
fi

# Print next steps
echo "======================================="
echo "Next Steps"
echo "======================================="
echo ""
echo "Claude Code is ready! Now complete the setup:"
echo ""
echo "1. Start Claude Code:"
echo "   ${GREEN}claude code${NC}"
echo ""
echo "2. In Claude, say:"
echo "   ${GREEN}\"Please follow the instructions in CLAUDE.md to set up this server\"${NC}"
echo ""
echo "Claude will handle:"
echo "  • System updates and patches"
echo "  • Tailscale VPN setup"
echo "  • Development tool installation (AWS CLI, GitHub CLI, etc.)"
echo "  • Python environment setup"
echo "  • Dotfile configuration"
echo "  • System verification"
echo ""
echo "Happy bootstrapping!"
echo ""
