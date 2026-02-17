# Linux Bootstrap Repository

This repository provides an automated way to bootstrap a new Linux server with all the tools and configurations you need. Instead of manually installing and configuring everything, you can clone this repo and let Claude Code handle the heavy lifting.

## What Gets Installed

This bootstrap process will set up:

- **System**: Fully patched Ubuntu/Debian system
- **Network**: Tailscale VPN
- **Development Tools**: AWS CLI, 1Password CLI, GitHub CLI, Cloudflare Wrangler
- **Terminal Tools**: Zellij (terminal multiplexer), Neovim (latest)
- **Python**: Python 3.14 and 3.13 with uv package manager
- **Dotfiles**: Pre-configured shell (.zshrc, .bashrc), git, and Neovim settings

## Prerequisites

Before starting, ensure your server has:
- **Git** - for cloning this repository
- **Curl** - for downloading installers
- **Ubuntu or Debian** - this bootstrap is designed for Debian-based systems

Most fresh server installations include git and curl by default. If not, install them:
```bash
sudo apt update && sudo apt install -y git curl
```

## Quick Start

### Option 1: One-Line Install (Fastest)

For the absolute fastest setup, run this single command:

```bash
curl -fsSL https://raw.githubusercontent.com/sswaner/linux-bootstrap/main/bootstrap.sh | bash
```

This will:
- Download and run the bootstrap script
- Install Claude Code CLI
- Provide instructions for the next steps

After this completes, clone the repository to access the full setup:
```bash
mkdir -p ~/code
cd ~/code
git clone https://github.com/sswaner/linux-bootstrap.git
cd linux-bootstrap
```

### Option 2: Manual Clone and Run

#### 1. Clone This Repository

```bash
mkdir -p ~/code
cd ~/code
git clone https://github.com/sswaner/linux-bootstrap.git
cd linux-bootstrap
```

#### 2. Run the Bootstrap Script

This installs Claude Code CLI:

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

The script will:
- Verify git and curl are available
- Install Claude Code CLI
- Provide next steps

### Next Step: Complete Setup with Claude Code

Once Claude Code is installed, have it execute the comprehensive setup:

```bash
claude code
# Then in the Claude interface, reference CLAUDE.md for setup instructions
# Or simply say: "Please follow the instructions in CLAUDE.md to set up this server"
```

Claude Code will:
- Install all development tools
- Configure Tailscale VPN
- Set up Python environments
- Copy dotfiles to your home directory
- Verify everything is working

## What's in This Repository

```
linux-bootstrap/
├── README.md              # This file - getting started guide
├── bootstrap.sh           # Minimal script to install Claude Code CLI
├── CLAUDE.md              # Detailed setup instructions for Claude Code
└── dotfiles/              # Configuration files
    ├── .zshrc             # ZSH shell configuration
    ├── .bashrc            # Bash shell configuration
    ├── .gitconfig         # Git configuration template
    └── nvim/              # Neovim configuration
        └── init.lua       # Neovim init file
```

## Customizing Your Setup

### Before Running Bootstrap

1. **Edit dotfiles**: Review and modify files in `dotfiles/` to match your preferences
2. **Edit CLAUDE.md**: Adjust the setup instructions if you want different tools or configurations
3. **Commit changes**: Keep your customizations in version control

### After Bootstrap

All dotfiles are copied to your home directory. You can edit them there:
- `~/.zshrc` - Shell configuration
- `~/.gitconfig` - Git settings
- `~/.config/nvim/init.lua` - Neovim settings

## Troubleshooting

### bootstrap.sh fails
- Verify git and curl are installed: `which git curl`
- Check internet connectivity: `ping -c 3 google.com`
- Review error messages for specific issues

### Claude Code installation fails
- Ensure you have sudo privileges
- Check system requirements for Claude Code
- Visit https://docs.anthropic.com/claude-code for manual installation

### Setup steps fail
- Claude Code will provide interactive feedback during setup
- You can run CLAUDE.md instructions multiple times (they're idempotent)
- Check individual tool documentation for specific issues

## Maintaining This Repository

As you refine your setup:

1. Update CLAUDE.md with new tools or configurations
2. Add/modify dotfiles as your preferences evolve
3. Commit and push changes so future servers get the latest setup
4. Test changes on a fresh VM or container when possible

## Why This Approach?

**Traditional approach**: Manually install each tool, configure each service, copy dotfiles, forget what you did

**This approach**:
- Clone repo → run one script → let AI do the rest
- Consistent setup across all servers
- Version controlled configuration
- Easy to update and maintain
- Reproducible environments

## License

This is your personal bootstrap repository. Use it however you like!
