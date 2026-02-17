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

### Option 1: Interactive One-Liner (Easiest)

Just run this command and paste your credentials when prompted:

```bash
curl -fsSL https://raw.githubusercontent.com/sswaner/linux-bootstrap/main/bootstrap.sh | bash
```

**The script will prompt you for:**
1. Your Anthropic API key (from [console.anthropic.com](https://console.anthropic.com/))
2. Your Tailscale auth key (from [Tailscale Admin](https://login.tailscale.com/admin/settings/keys))
3. Your 1Password service account token (optional, press Enter to skip)

**Then it automatically runs a two-phase process:**

**Phase 1 - Setup:**
- Clones this repository to `~/code/linux-bootstrap`
- Installs Claude Code CLI
- Runs the complete setup (system updates, Tailscale join, all tools)
- Joins your Tailscale network
- Configures all dotfiles

**Phase 2 - Verification & Improvement:**
- Verifies all tools are installed and working
- Compares actual state against expected state in CLAUDE.md
- If gaps found, attempts to fix them
- Updates repository files if improvements are needed
- Creates a pull request with proposed fixes (if any)

**That's it!** One command, paste three credentials, and you get:
- ✅ Fully configured server
- ✅ Self-verification of the setup
- ✅ Automatic improvement PRs if issues are found

### Option 2: Fully Automated (For Scripts/Automation)

For completely non-interactive setup (e.g., from Claude Code or scripts):

```bash
export ANTHROPIC_API_KEY='sk-ant-...'
export TAILSCALE_AUTH_KEY='tskey-auth-...'
export OP_SERVICE_ACCOUNT_TOKEN='ops_...'  # Optional

curl -fsSL https://raw.githubusercontent.com/sswaner/linux-bootstrap/main/bootstrap.sh | bash
```

If credentials are already set as environment variables, the script skips prompts.

### Option 3: Using 1Password to Retrieve Credentials

If you store credentials in 1Password's automation vault, retrieve and export them first:

```bash
# On your local machine with 1Password CLI:
export OP_SERVICE_ACCOUNT_TOKEN='ops_...'
export ANTHROPIC_API_KEY=$(op read "op://automation/anthropic-api-key/credential")
export TAILSCALE_AUTH_KEY=$(op read "op://automation/tailscale-auth-key/credential")

# Then SSH to your new server and run:
ssh user@newserver
curl -fsSL https://raw.githubusercontent.com/sswaner/linux-bootstrap/main/bootstrap.sh | bash
# Script detects env vars and skips prompts
```

Or pipe the credentials directly via SSH:

```bash
ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
TAILSCALE_AUTH_KEY="$TAILSCALE_AUTH_KEY" \
OP_SERVICE_ACCOUNT_TOKEN="$OP_SERVICE_ACCOUNT_TOKEN" \
  ssh user@newserver 'curl -fsSL https://raw.githubusercontent.com/sswaner/linux-bootstrap/main/bootstrap.sh | bash'
```

### Option 4: Manual Clone (If You Want to Customize First)

If you want to customize dotfiles or CLAUDE.md before running setup:

#### 1. Clone This Repository

```bash
mkdir -p ~/code
cd ~/code
git clone https://github.com/sswaner/linux-bootstrap.git
cd linux-bootstrap
```

#### 2. Customize (Optional)

Edit any files you want to customize:
- `dotfiles/.zshrc` - Shell configuration
- `dotfiles/.gitconfig` - Git settings
- `CLAUDE.md` - Setup instructions
- `dotfiles/nvim/init.lua` - Neovim config

#### 3. Run the Bootstrap Script

```bash
./bootstrap.sh
```

The script will prompt for credentials (or use env vars if already set), then automatically:
- Install Claude Code CLI
- Run the complete setup via Claude Code
- Join Tailscale network
- Install all tools and configure dotfiles

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

## Security Note

**Never commit credentials to this repository!**

All sensitive credentials are passed as environment variables:
- Store them in 1Password or another secure credential manager
- Export them only when running the bootstrap script
- The bootstrap script does not log or persist these values

**Recommended**: Store all credentials in 1Password's automation vault and retrieve them when needed.

### Required Credentials in 1Password Automation Vault

For fully automated server setup, store these credentials in your 1Password automation vault:

**Required for Bootstrap:**
- `anthropic-api-key` - Your Anthropic API key (starts with `sk-ant-`)
- `tailscale-auth-key` - Tailscale reusable auth key (starts with `tskey-auth-`)
- `1password-service-account-token` - 1Password service account token (starts with `ops_`)

**Required for PR Creation (Phase 2):**
- `github-token` - GitHub personal access token with `repo` scope for creating PRs
  - Create at: https://github.com/settings/tokens/new
  - Scopes needed: `repo`, `workflow`
  - The verification phase will use this to create improvement PRs

**Recommended for Full Automation:**
- `aws-access-key-id` - AWS access key ID for `aws` CLI
- `aws-secret-access-key` - AWS secret access key for `aws` CLI
- `cloudflare-api-token` - Cloudflare API token for Wrangler authentication

**Optional (User-Specific):**
- `git-user-name` - Your name for git commits
- `git-user-email` - Your email for git commits

**Note**: If GitHub token is not provided, the verification phase will still run but won't be able to create PRs automatically. It will provide the improvements locally for manual PR creation.

## Why This Approach?

**Traditional approach**: SSH into server → manually install each tool → configure each service → copy dotfiles → spend hours → forget what you did → repeat on next server

**This automated approach**:
- ✨ One command to go from fresh server to fully configured
- 🤖 Let AI handle the tedious installation and configuration
- 📝 Version controlled configuration (no more "how did I configure that?")
- 🔄 Consistent setup across all servers
- ⚡ Save hours on every new server setup
- 🔒 Secure credential handling via environment variables

## License

This is your personal bootstrap repository. Use it however you like!
