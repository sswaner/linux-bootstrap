# Linux Server Setup Instructions

This file contains comprehensive instructions for setting up a new Linux server. Follow these steps in order to install all necessary tools and configurations.

## Overview

This setup process will:
1. Update and patch the system
2. Install and configure Tailscale VPN
3. Install development tools (AWS CLI, 1Password CLI, GitHub CLI, Wrangler)
4. Install terminal tools (Zellij, Neovim)
5. Set up Python environments (3.14 and 3.13 with uv)
6. Copy and configure dotfiles
7. Verify all installations

## Prerequisites

- Ubuntu or Debian-based system
- Sudo privileges
- Internet connectivity
- This repository cloned to ~/code/linux-bootstrap
- Environment variables set (handled by bootstrap.sh):
  - `ANTHROPIC_API_KEY` - For Claude Code authentication
  - `TAILSCALE_AUTH_KEY` - For headless Tailscale join
  - `OP_SERVICE_ACCOUNT_TOKEN` (optional) - For 1Password CLI authentication

## Instructions

### 1. System Updates

Update the system and install all available patches:

```bash
sudo apt update
sudo apt upgrade -y
sudo apt dist-upgrade -y
sudo apt autoremove -y
sudo apt autoclean
```

**Note**: If the kernel was updated, you'll need to reboot the system:
```bash
sudo reboot
```

After reboot, reconnect and continue with the next steps.

### 2. Network & VPN

#### Install Tailscale

```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

#### Start and authenticate Tailscale

**Headless Mode (Recommended):**

If the `TAILSCALE_AUTH_KEY` environment variable is set, use it for unattended authentication:

```bash
if [ -n "$TAILSCALE_AUTH_KEY" ]; then
    sudo tailscale up --auth-key="$TAILSCALE_AUTH_KEY" --ssh
    echo "✓ Tailscale connected via auth key"
else
    echo "Warning: TAILSCALE_AUTH_KEY not set, falling back to interactive mode"
    sudo tailscale up --ssh
    echo "Please open the URL above in a browser to authenticate"
fi
```

Verify Tailscale is connected:
```bash
tailscale status
```

**Note**: The `--ssh` flag enables Tailscale SSH for remote access.

### 3. Development Tools

#### AWS CLI v2

```bash
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip
```

Verify installation:
```bash
aws --version
```

#### 1Password CLI

```bash
cd /tmp
curl -fsSL https://downloads.1password.com/linux/debian/amd64/stable/1password-cli-latest-amd64.deb -o 1password-cli.deb
sudo dpkg -i 1password-cli.deb
rm 1password-cli.deb
```

Verify installation:
```bash
op --version
```

**1Password Service Account (Optional):**

If the `OP_SERVICE_ACCOUNT_TOKEN` environment variable is set, configure it:

```bash
if [ -n "$OP_SERVICE_ACCOUNT_TOKEN" ]; then
    export OP_SERVICE_ACCOUNT_TOKEN
    echo "✓ 1Password service account token configured"
    # Test the connection
    op whoami || echo "Warning: Could not authenticate with 1Password"
else
    echo "Note: OP_SERVICE_ACCOUNT_TOKEN not set, skipping 1Password authentication"
fi
```

#### GitHub CLI

```bash
sudo mkdir -p -m 755 /etc/apt/keyrings
wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install -y gh
```

Verify installation:
```bash
gh --version
```

**Note**: GitHub CLI authentication is skipped during headless setup. Users can authenticate later with `gh auth login` when needed.

#### Cloudflare Wrangler

First ensure npm/node is available:
```bash
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs
```

Install Wrangler:
```bash
sudo npm install -g wrangler
```

Verify installation:
```bash
wrangler --version
```

### 4. Terminal Tools

#### Zellij (Terminal Multiplexer)

```bash
cd /tmp
ZELLIJ_VERSION=$(curl -s https://api.github.com/repos/zellij-org/zellij/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
curl -fsSL "https://github.com/zellij-org/zellij/releases/download/v${ZELLIJ_VERSION}/zellij-x86_64-unknown-linux-musl.tar.gz" -o zellij.tar.gz
tar -xzf zellij.tar.gz
sudo mv zellij /usr/local/bin/
rm zellij.tar.gz
```

Verify installation:
```bash
zellij --version
```

#### Neovim (Latest Version)

```bash
cd /tmp
curl -fsSL https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz -o nvim.tar.gz
tar -xzf nvim.tar.gz
sudo mv nvim-linux64 /opt/nvim
sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/vim
rm nvim.tar.gz
```

Verify installation:
```bash
nvim --version
vim --version
```

### 5. Python Environment

#### Install uv (Python Package Manager)

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Source the shell configuration to make uv available:
```bash
source $HOME/.cargo/env
```

#### Install Python 3.14 and 3.13

```bash
uv python install 3.14
uv python install 3.13
```

#### Install Python Development Headers

```bash
sudo apt install -y python3-dev python3-pip python3-venv
```

Verify Python installations:
```bash
uv python list
python3 --version
```

### 6. Configuration Files

#### Create necessary directories

```bash
mkdir -p ~/.config/nvim
```

#### Copy dotfiles from repository

Assuming the repository is at ~/code/linux-bootstrap:

```bash
# Backup existing files if they exist
[ -f ~/.zshrc ] && cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
[ -f ~/.bashrc ] && cp ~/.bashrc ~/.bashrc.backup.$(date +%Y%m%d_%H%M%S)
[ -f ~/.gitconfig ] && cp ~/.gitconfig ~/.gitconfig.backup.$(date +%Y%m%d_%H%M%S)
[ -f ~/.config/nvim/init.lua ] && cp ~/.config/nvim/init.lua ~/.config/nvim/init.lua.backup.$(date +%Y%m%d_%H%M%S)

# Copy new dotfiles
cp ~/code/linux-bootstrap/dotfiles/.zshrc ~/.zshrc
cp ~/code/linux-bootstrap/dotfiles/.bashrc ~/.bashrc
cp ~/code/linux-bootstrap/dotfiles/.gitconfig ~/.gitconfig
cp ~/code/linux-bootstrap/dotfiles/nvim/init.lua ~/.config/nvim/init.lua
```

#### Install ZSH (if not already installed)

```bash
sudo apt install -y zsh
```

**Headless Mode**: Default shell change is skipped during automated setup. Users can change later with:
```bash
chsh -s $(which zsh)
```

#### Configure Git

The `.gitconfig` file from dotfiles contains template values. In headless mode, git config is left as-is from the dotfiles. Users should update their name and email after setup:

```bash
# Users can update these values later:
# git config --global user.name "Your Name"
# git config --global user.email "your.email@example.com"
```

Verify git config was copied:
```bash
git config --global --list
```

### 7. Verification

Run verification checks for all installed tools:

```bash
echo "=== System Information ==="
uname -a
lsb_release -a

echo ""
echo "=== Installed Tool Versions ==="
echo "Tailscale: $(tailscale version)"
echo "AWS CLI: $(aws --version)"
echo "1Password CLI: $(op --version)"
echo "GitHub CLI: $(gh --version)"
echo "Wrangler: $(wrangler --version)"
echo "Zellij: $(zellij --version)"
echo "Neovim: $(nvim --version | head -n1)"
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"
echo "uv: $(uv --version)"
echo "Python 3.14: $(uv run python3.14 --version 2>/dev/null || echo 'Not available')"
echo "Python 3.13: $(uv run python3.13 --version 2>/dev/null || echo 'Not available')"
echo "Python (system): $(python3 --version)"
echo "ZSH: $(zsh --version)"

echo ""
echo "=== System Updates ==="
sudo apt update > /dev/null 2>&1
UPDATES=$(apt list --upgradable 2>/dev/null | grep -c upgradable)
if [ "$UPDATES" -le 1 ]; then
    echo "✓ System is fully up to date"
else
    echo "! $UPDATES packages can be updated"
fi

echo ""
echo "=== Dotfiles ==="
[ -f ~/.zshrc ] && echo "✓ .zshrc configured" || echo "✗ .zshrc missing"
[ -f ~/.bashrc ] && echo "✓ .bashrc configured" || echo "✗ .bashrc missing"
[ -f ~/.gitconfig ] && echo "✓ .gitconfig configured" || echo "✗ .gitconfig missing"
[ -f ~/.config/nvim/init.lua ] && echo "✓ nvim/init.lua configured" || echo "✗ nvim/init.lua missing"

echo ""
echo "=== Network ==="
tailscale status | head -n 5

echo ""
echo "=========================================="
echo "✓ Server setup complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  • Authenticate GitHub CLI: gh auth login"
echo "  • Configure AWS credentials: aws configure"
echo "  • Authenticate Wrangler: wrangler login"
echo "  • Authenticate 1Password CLI: op signin"
echo "  • Reload shell to apply dotfile changes: exec \$SHELL"
echo ""
```

## Expected Final State

After successful completion of all setup steps, the server should have:

### Installed Tools
- **Tailscale**: Installed, running, and connected to network
- **AWS CLI**: v2 installed (`aws --version` works)
- **1Password CLI**: Installed (`op --version` works)
- **GitHub CLI**: Installed (`gh --version` works)
- **Wrangler**: Installed (`wrangler --version` works)
- **Node.js**: LTS version installed (`node --version` works)
- **npm**: Installed (`npm --version` works)
- **Zellij**: Latest version installed (`zellij --version` works)
- **Neovim**: Latest version installed (`nvim --version` works)
- **ZSH**: Installed and available (`zsh --version` works)
- **uv**: Python package manager installed (`uv --version` works)
- **Python 3.14**: Installed via uv (`uv run python3.14 --version` works)
- **Python 3.13**: Installed via uv (`uv run python3.13 --version` works)

### Configured Files
- **~/.zshrc**: Shell configuration in place
- **~/.bashrc**: Shell configuration in place
- **~/.gitconfig**: Git configuration in place
- **~/.config/nvim/init.lua**: Neovim configuration in place

### System State
- **System patches**: Fully up to date (0 or 1 upgradable packages)
- **Tailscale network**: Connected and accessible
- **Repository**: Cloned to ~/code/linux-bootstrap

### Symbolic Links
- **/usr/local/bin/vim**: Points to nvim
- **/usr/local/bin/nvim**: Exists and is executable

### Verification Commands
These commands should all succeed:
```bash
tailscale status
aws --version
op --version
gh --version
wrangler --version
node --version
npm --version
zellij --version
nvim --version
vim --version
zsh --version
uv --version
python3 --version
test -f ~/.zshrc && echo "zshrc OK"
test -f ~/.bashrc && echo "bashrc OK"
test -f ~/.gitconfig && echo "gitconfig OK"
test -f ~/.config/nvim/init.lua && echo "nvim config OK"
```

## Notes

- All installation steps are designed to be idempotent (safe to run multiple times)
- Backups are created before overwriting existing dotfiles
- Some tools may require authentication after installation (GitHub CLI, AWS CLI, etc.)
- Reboot may be required if kernel updates were installed
- The user may need to complete interactive authentication steps for some services

## Troubleshooting

If any step fails:
1. Check internet connectivity
2. Verify sudo privileges
3. Review error messages carefully
4. Consult individual tool documentation
5. Retry the failed step after resolving issues

Most installation failures are due to network issues or missing dependencies. The error messages will typically indicate what went wrong.
