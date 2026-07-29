# tahioN - Cyberpunk IRC Server Automation Suite

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Bash](https://img.shields.io/badge/Bash-5.x+-green.svg)](https://www.gnu.org/software/bash/)
[![Debian](https://img.shields.io/badge/Debian-Trixie-orange.svg)](https://www.debian.org/)

**tahioN** is a cyberpunk-themed, bash-based automation suite for provisioning modern IRC server infrastructure on Debian Trixie systems. Originally created for the tahioSyndykat IRC community, it transforms a fresh Debian installation into a fully-featured IRC server with modern shell environments, security hardening, and cyberpunk aesthetics.

![tahioN Cyberpunk Interface](https://img.shields.io/badge/cyberpunk-v1.3-brightgreen?style=for-the-badge)

## 🚀 Quick Start

### Requirements

- **OS**: Debian Trixie (Testing) - fresh installation recommended
- **Privileges**: Root access required
- **Network**: IPv4 or IPv6 connectivity
- **Memory**: Minimum 2GB RAM
- **Disk**: 10GB free space

### Installation

Run the script with required parameters:

```bash
bash tahioN.sh <SSH_PORT> <SERVER_NAME>
```

**Example:**
```bash
bash tahioN.sh 2222 myserver
```

The script will:
1. Display Matrix-themed intro animation
2. Prompt for confirmation to proceed
3. Execute 10 automated installation phases
4. Interactively create admin accounts

## ⭐ Key Features

### 🔌 IPv6-First Networking
- **Automatic network detection**: IPv4, IPv6-only, or dual-stack
- **GitHub proxy fallback**: Uses `danwin1210.de:1443` for IPv6-only networks
- **Dual-stack SSH**: Listens on both IPv4 and IPv6 addresses

### 🎨 Cyberpunk User Experience
- **Matrix intro animation**: Full-screen ASCII art with matrix rain effect
- **Real-time progress bar**: Cyberpunk-themed installation tracker
- **Open-ended frame design**: UTF-8 icons without right borders
- **Powerlevel10k integration**: Rich terminal themes for admin users

### 🛡️ Security Hardening
- **Custom SSH port**: User-defined port from parameter
- **Fail2Ban integration**: Brute-force protection
- **Disabled root login**: SSH root access blocked
- **Passwordless sudo**: For created admin accounts
- **Dual-stack firewall**: IPv4 and IPv6 protection

### 🏗️ Modern Shell Environment
- **Zsh with zinit**: Global plugin manager setup
- **Modern CLI tools**: eza, zoxide, fzf, starship
- **Syntax highlighting**: Real-time command syntax highlighting
- **Auto-suggestions**: Intelligent command completion
- **Fuzzy finding**: Advanced file search capabilities

### 🤖 IRC Infrastructure
- **Eggdrop 1.8.4**: Classic IRC bot with SHA256 verification
- **Psotnic**: Modern IRC bot compilation
- **KNB**: Game bot for IRC entertainment
- **ZNC**: Advanced IRC bouncer
- **Caddy**: Modern web server with automatic HTTPS

### 📊 Management Tools
The suite includes 22 management commands installed to `/bin/`:

**Root Commands (requires sudo):**
- `add` - Create new user accounts
- `block/unblock` - Account management
- `del/udel` - User deletion utilities
- `get-egg/get-psotnic/get-znc` - IRC bot installers
- `rebind` - Restart BIND9 DNS
- `unban` - Fail2Ban management

**User Commands:**
- `ile` - Show active IRC connections
- `vhosts` - Display virtual hosts
- `v6it` - Show IPv6 addresses for irc6.tophost.it
- `knb` - Interactive KNB game
- `pomoc` - Help system and command list

## 🏗️ Architecture - 10 Installation Phases

### Phase 1: IPv6 Network Detection (lines 282-305)
```bash
do_ipv6_setup()
```
- Pings `8.8.8.8` (IPv4 test) and `2001:4860:4860::8888` (IPv6 test)
- Sets `${GITHUB_URL}` variable:
  - IPv4 available: `https://github.com`
  - IPv6-only: `https://danwin1210.de:1443`
- Exports `${IPV6_ONLY}` flag for other functions

### Phase 2: APT Repository Sync (lines 589-642)
```bash
do_apt()
```
- Updates package repositories
- **IRC Tools**: znc, oidentd, irssi
- **IRC Bot Dependencies**: eggdrop, tcl
- **Modern Shell**: zsh, fzf (0.60.3+), eza, zoxide
- **Security**: fail2ban, bind9
- **Web Stack**: caddy, php-cli, php-fpm
- **Build Tools**: build-essential, meson, ninja-build, cmake
- **Dev Libraries**: libglib2.0-dev, libutf8proc-dev, libncurses-dev

### Phase 3: Zsh + Modern CLI Tools (lines 309-471)
```bash
do_zsh_setup()
```
- Installs **zinit** globally to `/usr/local/share/zinit`
- Creates `/etc/skel/.zshrc` with:
  - Zinit plugin manager
  - Plugins: zsh-syntax-highlighting, zsh-completions, zsh-autosuggestions
  - Modern fzf integration: `source <(fzf --zsh)`
  - eza aliases (ls replacement with icons)
  - zoxide integration (smart cd)
  - Helper functions: mkcd, backup, ex, gcommit, killport

### Phase 4: SSH Hardening & Fail2Ban (lines 721-779)
```bash
do_sshd_f2b()
```
- **Fail2Ban Configuration**:
  - Trusted IPs: `127.0.0.1/8` only
  - Max attempts: 4
  - SSH port: custom from parameter
- **SSH Hardening**:
  - Custom port (from parameter)
  - Disabled root login
  - IPv6/IPv4 listen based on network type
  - PAM authentication, X11 forwarding enabled
  - Custom banner from `/etc/banner`
- **DNS Resolvers**: Google, Cloudflare, Quad9 (IPv4 + IPv6)

### Phase 5: Cyberpunk MOTD System (lines 475-587)
```bash
do_motd_cyberpunk()
```
- **Proper Debian MOTD**: `/etc/update-motd.d/` modular scripts
- Creates `/etc/tahion/ads.txt` with rotating links:
  - `⚡ erssi.org - Modern IRC Client`
  - `⬢ sshm.io - SSH Management Tool`
  - `∞ tb.tahio.eu - TahioN Toolbox`
- **Modular MOTD Scripts**:
  - `00-header`: ASCII art with random ad
  - `10-sysinfo`: System status (hostname, kernel, uptime, memory, IPv4/IPv6)
  - `50-diskspace`: Disk usage display

### Phase 6: BIND9 DNS Configuration (lines 781-832)
```bash
do_bind()
```
- Configures BIND9 for reverse DNS (IPv6 focus)
- Template configuration in `/etc/bind/`
- IPv6 reverse DNS setup

### Phase 7: Eggdrop Bot Assembly (lines 1105-1273)
```bash
do_egg()
```
- Downloads Eggdrop 1.8.4 from `ftp.eggheads.org`
- Verifies SHA256 checksum: `79644eb27a5568934422fa194ce3ec21cfb9a71f02069d39813e85d99cdebf9e`
- Compiles with IPv6 support
- Creates template configuration
- Installs to `/bin/eggdrop` and `/bin/tools/egg.tar.gz`

### Phase 8: Psotnic Bot Deployment (lines 1274-1288)
```bash
do_post()
```
- Clones from `${GITHUB_URL}/kofany/psotnic`
- Compiles with `./configure && make dynamic`
- Installs to `/bin/psotnic`

### Phase 9: KNB Bot Initialization (lines 1291-1304)
```bash
do_knb()
```
- Clones from `${GITHUB_URL}/kofany/knb`
- Compiles without validator
- Installs to `/bin/knb`

### Phase 10: Binary Update & Finalization (lines 1307-1355)
```bash
do_update()
```
- Downloads from `${GITHUB_URL}/kofany/tahioN/raw/main/update.tar.gz`
- Replaces binaries in `/bin/`
- Uses wget without `-4` flag (supports both IPv4/IPv6)

## 🎨 Cyberpunk UI System

### Progress Bar Features
The script uses a cyberpunk-themed progress bar with **open-ended frame design**:

**Visual Elements:**
- Header: `⚡ tahioN v1.3 ⚡` + `DEPLOYING IRC MAINFRAME`
- Progress bar: `[████████████░░░░░░]` with percentage
- Task icons: `✓` (completed), animated spinner `⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏` (active), `○` (pending)
- Elapsed time: `⧗ ELAPSED: MM:SS`
- Footer: `made with <3 by kofany & yooz`

**Task Names:**
```bash
TASKS_NAMES=(
    "⚡ IPv6 network detection & GitHub proxy setup"
    "⬢ APT repository synchronization & package matrix"
    "∞ Zsh + modern CLI tools deployment (eza/zoxide/fzf)"
    "◆ SSH hardening & Fail2Ban protection matrix"
    "⧗ MOTD cyberpunk matrix deployment"
    "⚙ BIND9 DNS server configuration"
    "➜ Eggdrop bot assembly v1.8.4"
    "➜ Psotnic bot deployment sequence"
    "➜ KNB bot initialization protocol"
    "⚡ Binary update & system finalization"
)
```

### Matrix Intro Animation
The script includes a full-screen Matrix-themed intro:
- Matrix rain effect with Japanese katakana symbols
- Fade-in logo animation
- Typewriter effect for system messages
- Red pill/Blue pill choice prompt
- Clean terminal reset before main installation

## 🔧 Configuration

### SSH Configuration
The script modifies `/etc/ssh/sshd_config`:
- **Port**: Custom from parameter (1-65535)
- **PermitRootLogin**: No
- **ListenAddress**: Based on network type
- **PasswordAuthentication**: Yes
- **X11Forwarding**: Yes
- **Banner**: `/etc/banner`

### Fail2Ban Configuration
Created `/etc/fail2ban/jail.local`:
- **SSH port**: Custom from parameter
- **Maxretry**: 4
- ** Bantime**: 600 seconds
- **Findtime**: 600 seconds
- **Trusted IP**: `127.0.0.1/8` only

### DNS Configuration
System resolvconf updated with:
- **Google**: `8.8.8.8`, `2001:4860:4860::8888`
- **Cloudflare**: `1.1.1.1`, `2606:4700:4700::1111`
- **Quad9**: `9.9.9.9`, `2620:fe::fe`

### Zsh Configuration
All users get modern shell environment:
```zsh
# Core plugins (all users)
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Modern CLI tools
alias ls='eza -la --icons'
alias ll='eza -la'
alias lt='eza --tree'

# zoxide (smart cd)
eval "$(zoxide init zsh)"

# fzf integration
source <(fzf --zsh)
```

**Sudo users** additionally get:
- Powerlevel10k theme
- Instant prompt configuration
- Enhanced visual experience

## 🔒 Security Considerations

### ⚠️ Important Security Notes

1. **No Automatic Backdoors**: User creation is interactive, requires explicit confirmation
2. **Credentials Display**: User credentials shown on screen only (no email/logging)
3. **Passwordless Sudo**: Admin accounts get `NOPASSWD:ALL` - **change in production**
4. **SSH Hardening**: Custom port, no root login, Fail2Ban protection
5. **Dual-Stack Security**: Both IPv4 and IPv6 protected by Fail2Ban
6. **External Dependencies**: Downloads from GitHub and eggheads.org - verify sources
7. **Root Execution**: Makes system-wide changes - review before running
8. **Production Use**: Change generated passwords after first login

### Recommended Post-Installation Security Steps

1. **Change sudo password policy**:
   ```bash
   sudo visudo
   # Remove NOPASSWD and require password for sudo operations
   ```

2. **Update SSH keys**:
   ```bash
   # Replace with your SSH keys
   mkdir -p ~/.ssh
   chmod 700 ~/.ssh
   cp your_public_key.pub ~/.ssh/authorized_keys
   chmod 600 ~/.ssh/authorized_keys
   ```

3. **Disable password authentication**:
   ```bash
   sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
   sudo systemctl restart ssh
   ```

4. **Update system packages**:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

## 🌍 IPv6 Support Details

### Network Detection Logic

```bash
# Test IPv4 connectivity
if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
    GITHUB_URL="https://github.com"
    IPV6_ONLY=false
else
    # Test IPv6 connectivity
    if ping -c 1 -W 2 2001:4860:4860::8888 >/dev/null 2>&1; then
        GITHUB_URL="https://danwin1210.de:1443"  # GitHub IPv6 proxy
        IPV6_ONLY=true
    fi
fi
```

### GitHub Operations Using IPv6

All GitHub operations use `${GITHUB_URL}` variable:
- `git clone ${GITHUB_URL}/kofany/psotnic`
- `git clone ${GITHUB_URL}/zdharma-continuum/zinit.git`
- `wget "${GITHUB_URL}/kofany/tahioN/raw/main/update.tar.gz"`

### SSH Listening Configuration

**IPv6-only networks:**
```bash
ListenAddress ::
```

**Dual-stack networks:**
```bash
ListenAddress 0.0.0.0
ListenAddress ::
```

## 📝 Usage Examples

### Basic Installation
```bash
# Install on server "myirc" with SSH on port 2222
bash tahioN.sh 2222 myirc
```

### Interactive User Creation
After installation, the script prompts:
```
⚡ Create sudo admin accounts? [y/n]
⬢ Enter usernames (space-separated, e.g: user1 user2 user3):
```

**Example input:**
```
y
admin1 admin2 botmaster
```

**Generated output:**
```
╔═══[⚡ ACCESS CREDENTIALS GENERATED ⚡]
║
║ ⬢ Server IP:  203.0.113.42
║ ⬢ SSH Port:   2222
║
║ ➜ User:     admin1
║ ➜ Password: K7mP9xQ2v
║
║ ➜ User:     admin2
║ ➜ Password: B4nL8wE5t
║
║ ➜ User:     botmaster
║ ➜ Password: X9cR3hN6j
```

### Post-Installation Commands

**Create new user:**
```bash
sudo add newuser
```

**Install Eggdrop bot:**
```bash
sudo get-egg botname
```

**Check IRC connections:**
```bash
ile
```

**Display help:**
```bash
pomoc
```

## 🛠️ Development

### Modifying the Script

#### Adding a New Installation Phase

1. Create function following existing patterns:
```bash
do_newfeature() {
    # Your code here
    # Ensure all output redirects to /dev/null
    # Use ${GITHUB_URL} for GitHub operations
}
```

2. Add task name to `init_tasks()`:
```bash
TASKS_NAMES+=("🆕 New feature description")
```

3. Add to main execution sequence:
```bash
# Task X: New cyberpunk task
start_task X
do_newfeature >/dev/null 2>&1
complete_task X
```

#### Modifying MOTD

Edit modular scripts in `do_motd_cyberpunk()`:
- `/etc/update-motd.d/00-header` - Header and random ads
- `/etc/update-motd.d/10-sysinfo` - System information
- `/etc/update-motd.d/50-diskspace` - Disk usage

Add new ads to `/etc/tahion/ads.txt`:
```bash
⚡ erssi.org - Modern IRC Client
⬢ sshm.io - SSH Management Tool  
∞ tb.tahio.eu - TahioN Toolbox
🎮 yoursite.com - Your Service
```

#### Cyberpunk UI Design Rules

- **Use open-ended frames**: Left border only, no right border
- **UTF-8 icons**: ⚡⧗∞⬢⚙◆➜✓○⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏
- **Box drawing**: `╔═╠╚║` (no `╗╣╝` right-side chars)
- **Color scheme**: Cyan frames, yellow highlights, green success, gray inactive

### Testing

#### Test Environments
- **Requirements**: Disposable VM/container (makes system-wide changes)
- **OS**: Debian Trixie (Testing) recommended
- **Privileges**: Root access

#### Test Scenarios

**IPv4 Network Test:**
```bash
# Should use https://github.com directly
bash tahioN.sh 2222 test-ipv4
```

**IPv6-only Network Test:**
```bash
# Should fallback to https://danwin1210.de:1443
bash tahioN.sh 2222 test-ipv6
```

**Dual-stack Test:**
```bash
# Should use GitHub directly, listen on both IP versions
bash tahioN.sh 2222 test-dual
```

## 📦 Dependencies

### From Debian Trixie Repositories
- **Shell**: zsh, fzf (0.60.3+)
- **Modern Tools**: eza, zoxide (no cargo compilation needed)
- **Web**: caddy, php-fpm (replaced Apache2)
- **Build**: meson, ninja-build, build-essential

### External Downloads
- **Eggdrop 1.8.4**: From eggheads.org (SHA256 verified)
- **Psotnic**: From GitHub via `${GITHUB_URL}`
- **KNB**: From GitHub via `${GITHUB_URL}`
- **Update Binaries**: From GitHub via `${GITHUB_URL}`
- **Zinit**: From GitHub (installed globally)

## 🤝 Contributing

### Development Setup

1. **Fork the repository**
2. **Create feature branch**:
   ```bash
   git checkout -b feature/your-feature
   ```
3. **Make changes** following coding standards
4. **Test on disposable environment**
5. **Submit pull request**

### Code Style Guidelines

- **Bash best practices**: Use `set -euo pipefail`
- **Function naming**: `do_feature_name()`
- **Variable naming**: UPPERCASE for globals, lowercase for locals
- **Output redirection**: Redirect to `/dev/null` for silent operations
- **Comments**: Document complex logic
- **UTF-8 support**: Ensure cyberpunk UI works with UTF-8

### Adding Features

When adding new features:

1. **Document in README**: Update architecture section
2. **Add tests**: Create test scenarios
3. **Update cyberpunk theme**: Add appropriate icons
4. **IPv6 support**: Use `${GITHUB_URL}` for GitHub operations
5. **Security review**: Consider security implications

## 📄 License

This project is licensed under the **GNU General Public License v3.0** - see the [LICENSE](LICENSE) file for details.

```
Copyright (C) 2024 kofany & yooz
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.
```

## 🆘 Troubleshooting

### Common Issues

#### Network Connectivity
```bash
# Test IPv4
ping -c 1 8.8.8.8

# Test IPv6
ping -c 1 2001:4860:4860::8888
```

#### Installation Fails
```bash
# Check log file
tail -f /var/log/tahion.log

# Verify system requirements
lsb_release -a
free -h
df -h
```

#### SSH Connection Issues
```bash
# Check SSH port
cat /var/log/ssh.txt

# Verify SSH service
systemctl status ssh

# Check Fail2Ban status
fail2ban-client status sshd
```

#### IRC Bot Issues
```bash
# Check installed binaries
ls -la /bin/eggdrop /bin/psotnic /bin/knb

# Test bot functionality
/bin/eggdrop --help
/bin/psotnic --help
```

### Getting Help

1. **Check logs**: `/var/log/tahion.log`
2. **Review configuration**: Files in `/etc/`
3. **Test connectivity**: Use provided ping tests
4. **Check permissions**: Ensure root execution
5. **Verify network**: Test IPv4/IPv6 connectivity

## 🎯 Roadmap

### Future Improvements

- [ ] **Automated testing suite**: Unit tests for all functions
- [ ] **Configuration file**: Customize task selection
- [ ] **Distribution support**: Other Debian-based systems
- [ ] **IPv6-only mode**: Dedicated IPv6 installation flag
- [ ] **Theme options**: Alternative visual themes
- [ ] **Security enhancements**: Improved password policies
- [ ] **Monitoring integration**: System metrics and alerting
- [ ] **Backup system**: Automated configuration backup
- [ ] **Docker support**: Containerized installation
- [ ] **Multi-server**: Cluster deployment capabilities

## 📊 Statistics

- **Lines of Code**: 1,597 (tahioN.sh)
- **Installation Phases**: 10
- **Commands Installed**: 22
- **Cyberpunk Icons**: 15+ Unicode symbols
- **Color Scheme**: 7 ANSI colors
- **Supported Protocols**: IPv4, IPv6, IRC, DNS, SSH
- **Configuration Files**: 15+ system files

## 👥 Authors

- **kofany** - *Initial work & Cyberpunk UI* - [@kofany](https://github.com/kofany)
- **yooz** - *Collaborator & Testing* - [@yooz](https://github.com/yooz)

## 🙏 Acknowledgments

- **tahioSyndykat IRC Community** - Original inspiration
- **Eggheads.org** - Eggdrop IRC bot
- **zdharma-continuum** - Zinit plugin manager
- **fzf** - Fuzzy finder tool
- **eza** - Modern ls replacement
- **zoxide** - Smart cd replacement
- **Powerlevel10k** - Zsh theme
- **Matrix community** - Inspiration for cyberpunk aesthetics

---

**Made with <3 by kofany & yooz**

*Welcome to the Matrix. Follow the white rabbit 🐇*

[![matrix](https://img.shields.io/badge/matrix-virtual_reality-red?style=for-the-badge)](https://en.wikipedia.org/wiki/The_Matrix)
[![irc](https://img.shields.io/badge/IRC-freenode-blue?style=for-the-badge)](https://freenode.net/)
[![cyberpunk](https://img.shields.io/badge/cyberpunk-2077-purple?style=for-the-badge)](https://en.wikipedia.org/wiki/Cyberpunk)