# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

tahioN is a **cyberpunk-themed** server automation script designed for IRC server infrastructure setup. It's a bash-based installation script that configures Debian Trixie systems with IRC-related tools, modern shell environments (Zsh + Powerlevel10k), security hardening, and interactive user management. Originally created for the tahioSyndykat IRC community, it's now designed for public sharing with IRC enthusiasts setting up modern shell accounts.

### Key Features

- **IPv6-first networking** with automatic GitHub proxy fallback for IPv6-only networks
- **Modern shell environment**: Zsh with Powerlevel10k theme, eza, zoxide, fzf
- **Cyberpunk aesthetic**: Progress bar and MOTD with UTF-8 icons and open-ended frame design
- **Security hardening**: SSH on custom port, Fail2Ban, disabled root login, dual-stack IPv4/IPv6
- **Interactive user creation**: No automatic backdoors, prompts for admin account creation
- **Professional progress tracking**: Real-time cyberpunk-styled progress bar with 10 installation phases

## Main Script: tahioN.sh

**Target OS**: Debian Trixie (Testing)

**Execution**: The script must be run as root with two required parameters:
```bash
bash tahioN.sh <SSH_PORT> <SERVER_NAME>
```

Example:
```bash
bash tahioN.sh 2222 myserver
```

### Core Architecture - 10 Installation Phases

The script executes in 10 sequential phases with cyberpunk-themed progress tracking:

#### 1. **do_ipv6_setup()** - IPv6 Network Detection (lines 282-305)
   - Detects network type: IPv4, IPv6-only, or dual-stack
   - Sets `${GITHUB_URL}` variable:
     - IPv4 available: `https://github.com`
     - IPv6-only: `https://danwin1210.de:1443` (GitHub IPv6 proxy)
   - Exports `${IPV6_ONLY}` flag for other functions
   - All GitHub operations use `${GITHUB_URL}` for IPv6 compatibility

#### 2. **do_apt()** - Package Installation (lines 589-642)
   - Updates system packages
   - **IRC tools**: znc, oidentd, irssi
   - **IRC bot dependencies**: eggdrop, tcl
   - **Modern shell tools**: zsh, fzf (0.60.3+), eza, zoxide
   - **Security**: fail2ban, bind9
   - **Web stack**: caddy, php-cli, php-fpm
   - **Build tools**: build-essential, meson, ninja-build, cmake, autotools
   - **Dev libraries**: libglib2.0-dev, libutf8proc-dev, libncurses-dev, libgcrypt20-dev, libotr5-dev

#### 3. **do_zsh_setup()** - Modern Shell Configuration (lines 309-471)
   - Installs **zinit** globally to `/usr/local/share/zinit` using `${GITHUB_URL}`
   - Creates `/etc/skel/.zshrc` with:
     - Zinit plugin manager
     - Plugins: zsh-syntax-highlighting, zsh-completions, zsh-autosuggestions, fzf-tab
     - Modern fzf integration: `source <(fzf --zsh)` (fzf 0.48.0+ method)
     - eza aliases (ls replacement with icons)
     - zoxide integration (smart cd)
     - Helper functions: mkcd, backup, ex, gcommit, killport
   - **No Powerlevel10k** in base config (reserved for sudo users)
   - All new users get modern zsh by default

#### 4. **do_sshd_f2b()** - SSH Hardening & Fail2Ban (lines 721-779)
   - **Fail2Ban configuration**:
     - Trusted IPs: `127.0.0.1/8` only (no hardcoded private IPs)
     - Max attempts: 4
     - SSH port: custom from parameter
   - **SSH hardening**:
     - Custom port (from parameter)
     - Disabled root login
     - Conditional IPv6/IPv4 listen:
       - IPv6-only: `ListenAddress ::`
       - Dual-stack: Both `0.0.0.0` and `::`
     - PAM authentication, X11 forwarding enabled
     - Custom banner from `/etc/banner`
   - **DNS resolvers**: Google, Cloudflare, Quad9 (IPv4 + IPv6)

#### 5. **do_motd_cyberpunk()** - Cyberpunk MOTD System (lines 475-587)
   - **Proper Debian MOTD system**: `/etc/update-motd.d/` modular scripts
   - Creates `/etc/tahion/ads.txt` with rotating links:
     - `⚡ erssi.org - Modern IRC Client`
     - `⬢ sshm.io - SSH Management Tool`
     - `∞ tb.tahio.eu - TahioN Toolbox`
   - **Modular MOTD scripts**:
     - `00-header`: ASCII art header with randomly selected ad from ads.txt
     - `10-sysinfo`: System status (hostname, kernel, uptime, load, memory, swap, IPv4, IPv6)
     - `50-diskspace`: Disk usage display
   - **Open-ended frame design**: No right border to avoid UTF-8 spacing issues
   - Disables old methods: `/etc/motd`, `/etc/profile.d/motd.sh`
   - Disables default Ubuntu/Debian MOTD scripts

#### 6. **do_bind()** - DNS Server Configuration (lines 781-832)
   - Configures BIND9 for reverse DNS (IPv6 focus)
   - Template configuration in `/etc/bind/`

#### 7. **do_egg()** - Eggdrop IRC Bot (lines 1105-1273)
   - Downloads and compiles Eggdrop 1.8.4
   - Verifies SHA256 checksum
   - Creates template configuration
   - Installs to `/bin/eggdrop` and `/bin/tools/egg.tar.gz`

#### 8. **do_post()** - Psotnic IRC Bot (lines 1274-1288)
   - Clones from `${GITHUB_URL}/kofany/psotnic` (IPv6 compatible)
   - Compiles with `./configure && make dynamic`
   - Installs to `/bin/psotnic`

#### 9. **do_knb()** - KNB Tool (lines 1291-1304)
   - Clones from `${GITHUB_URL}/kofany/knb` (IPv6 compatible)
   - Compiles without validator
   - Installs to `/bin/knb`

#### 10. **do_update()** - Binary Updates (lines 1307-1355)
   - Downloads from `${GITHUB_URL}/kofany/tahioN/raw/main/update.tar.gz` (IPv6 compatible)
   - Uses `wget` without `-4` flag (supports both IPv4/IPv6)
   - Replaces binaries in `/bin/`

#### Post-Installation: **do_admin()** - Interactive User Creation (lines 1225-1343)
   - Runs **after all installation tasks complete** (interactive)
   - Prompts: "Czy chcesz utworzyć konta użytkowników z uprawnieniami sudo? [t/n]"
   - Accepts multiple usernames separated by spaces
   - For each user:
     - Creates account with **zsh as default shell** (`useradd -m -s /bin/zsh`)
     - Generates random 10-character password
     - **Power user setup** (sudo users only):
       - Copies `/root/.p10k.zsh` to user's home
       - Updates `.zshrc` with Powerlevel10k instant prompt
       - Adds p10k theme to zinit configuration
     - Grants passwordless sudo (NOPASSWD:ALL)
   - Displays credentials in formatted table with IP, port, usernames, passwords
   - **No email sending** - credentials shown on screen only

### Progress Bar System - Cyberpunk Edition

The script uses a cyberpunk-themed progress bar with **open-ended frame design** (no right border to avoid UTF-8 width calculation issues):

#### Functions:
- **init_tasks()** (lines 45-65) - Initializes 10 tasks with cyberpunk names and UTF-8 icons
- **draw_progress()** (lines 67-136) - Renders cyberpunk UI:
  - Header: `⚡ tahioN v1.0 ⚡` + `DEPLOYING IRC MAINFRAME`
  - Progress bar: `[████████░░░░]` with percentage
  - Task list with icons: `✓` (completed), spinner `⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏` (active), `○` (pending)
  - Elapsed time: `⧗ ELAPSED: MM:SS`
  - Footer: `made with <3 by kofany & yooz`
  - **Open-ended frames**: Uses `╔═╠╚║` without right border
- **spinner_animation()** - Background process animating the spinner
- **start_task(index)** - Marks task in-progress, starts spinner
- **complete_task(index)** - Marks task completed, stops spinner

#### Task Names (Cyberpunk Edition):
```
0. ⚡ IPv6 network detection & GitHub proxy setup
1. ⬢ APT repository synchronization & package matrix
2. ∞ Zsh + modern CLI tools deployment (eza/zoxide/fzf)
3. ◆ SSH hardening & Fail2Ban protection matrix
4. ⧗ MOTD cyberpunk matrix deployment
5. ⚙ BIND9 DNS server configuration
6. ➜ Eggdrop bot assembly v1.8.4
7. ➜ Psotnic bot deployment sequence
8. ➜ KNB bot initialization protocol
9. ⚡ Binary update & system finalization
```

Example output:
```
╔═══[⚡ tahioN v1.0 ⚡]═══[DEPLOYING IRC MAINFRAME]
║
║  ⬢ SYSTEM INIT :: [████████████░░░░░░░░] 5/10 (50%)
║
╠═══════════════════════════════════════════════════════════════════
║
║  ✓ ⚡ IPv6 network detection & GitHub proxy setup
║  ✓ ⬢ APT repository synchronization & package matrix
║  ⠋ ∞ Zsh + modern CLI tools deployment (eza/zoxide/fzf)
║  ○ ◆ SSH hardening & Fail2Ban protection matrix
...
╠═══════════════════════════════════════════════════════════════════
║  ⧗ ELAPSED: 02:34
║
╚═══════════════════════════[made with <3 by kofany & yooz]
```

### Helper Functions

- **tt()** - Colored text output for messages
- **rm_file()** - Safe file deletion
- **yes_or_no()** - Interactive confirmation
- **banner()** - ASCII art display

### Key Configuration Files Created/Modified

- `/etc/tahion/ads.txt` - Rotating MOTD advertisements
- `/etc/update-motd.d/00-header` - MOTD header with random ad
- `/etc/update-motd.d/10-sysinfo` - System information display
- `/etc/update-motd.d/50-diskspace` - Disk usage display
- `/etc/skel/.zshrc` - Global zsh config for new users
- `/usr/local/share/zinit/zinit.git/` - Global zinit installation
- `/etc/banner` - SSH login banner
- `/etc/ssh/sshd_config` - SSH daemon config (custom port, IPv6 support)
- `/etc/fail2ban/jail.local` - Fail2Ban rules
- `/var/log/ssh.txt` - Stores SSH port number
- `/etc/sudoers` - Modified to add sudo users

### User Commands Installed

Root commands:
- `add` - User management
- `block`, `unblock`, `blocked`, `blocklist` - Account blocking
- `del`, `udel` - User deletion
- `get-egg`, `get-psotnic`, `get-znc` - IRC bot installers
- `ile` - Show active IRC connections
- `rebind` - Restart BIND9
- `unban` - Fail2Ban management
- `vhosts` - Display virtual hosts
- `v6it` - Show 2 IPs per /48 class for irc6.tophost.it
- `knb` - KNB game
- `pomoc` - Help/command list

Regular user commands:
- `get-egg`, `get-psotnic`, `get-znc`, `vhosts`, `knb`, `v6it`, `pomoc`

**Note**: Many commands are installed via `do_update()` which downloads binaries from `${GITHUB_URL}`.

## Working with This Codebase

### Reading and Understanding

#### Execution Flow:
1. Parameter validation (SSH port 1-65535, server name)
2. Root privilege check
3. Display banner and confirmation prompt
4. **IPv6 network detection** → sets `${GITHUB_URL}` variable
5. Initialize cyberpunk progress bar with 10 tasks
6. For each task: `start_task(X)` → `do_function()` → `complete_task(X)`
7. Progress bar shows real-time status with animated spinner
8. After all tasks: interactively prompt for admin account creation
9. Display credentials and final messages

#### Key Design Patterns:
- **IPv6-first**: All GitHub operations use `${GITHUB_URL}` variable
- **Silent execution**: All functions redirect output to `/dev/null`
- **Progress tracking**: Tasks update via `start_task()` / `complete_task()`
- **Open-ended UI**: Progress bar and MOTD avoid right borders (UTF-8 spacing)
- **Tier-based shell config**: Basic zsh for all, Powerlevel10k for sudo users only
- **Interactive security**: No automatic backdoors, prompts for account creation

### Modern Shell Environment

**All users** get:
- Zsh with zinit plugin manager
- Modern CLI tools: eza (ls), zoxide (cd), fzf (fuzzy finder)
- Syntax highlighting, autosuggestions, completions
- Git aliases, helper functions

**Sudo users** additionally get:
- Powerlevel10k theme with instant prompt
- Full `.p10k.zsh` configuration (91KB theme config)
- Configured automatically during account creation

### IPv6 Support Details

**Network detection** (`do_ipv6_setup()`):
- Pings `8.8.8.8` (IPv4 test) and `2001:4860:4860::8888` (IPv6 test)
- Sets `GITHUB_URL`:
  - IPv4 works: `https://github.com`
  - IPv4 fails, IPv6 works: `https://danwin1210.de:1443` (GitHub proxy)
  - Both fail: Exit with error

**All GitHub operations** use `${GITHUB_URL}`:
- `git clone ${GITHUB_URL}/kofany/psotnic`
- `git clone ${GITHUB_URL}/zdharma-continuum/zinit.git`
- `wget "${GITHUB_URL}/kofany/tahioN/raw/main/update.tar.gz"`

**SSH listening**:
- IPv6-only: `ListenAddress ::`
- Dual-stack: Both `0.0.0.0` and `::`

### Testing

**Requirements**:
- Disposable VM/container (makes system-wide changes)
- Debian Trixie (Testing) recommended
- Root access

**Test scenarios**:
1. **IPv4 network**: Should use `https://github.com` directly
2. **IPv6-only network**: Should fallback to `https://danwin1210.de:1443`
3. **Dual-stack**: Should use GitHub directly, listen on both IP versions

### Modifying

#### Adding a new installation phase:

1. Create `do_yourfunction()` following existing patterns
2. Ensure all output redirects to `/dev/null`
3. Use `${GITHUB_URL}` for any GitHub operations
4. Add task name to `init_tasks()` TASKS_NAMES array (with UTF-8 icon)
5. Add to main execution sequence (lines 1482-1530):
   ```bash
   # Task X: Your cyberpunk task description
   start_task X
   do_yourfunction >/dev/null 2>&1
   complete_task X
   ```
6. Update task indices if inserting in middle

#### Modifying MOTD:

Edit modular scripts in `do_motd_cyberpunk()`:
- `/etc/update-motd.d/00-header` - Header and random ad
- `/etc/update-motd.d/10-sysinfo` - System info
- `/etc/update-motd.d/50-diskspace` - Disk usage

Add new ads to `/etc/tahion/ads.txt` (one per line, use UTF-8 icons).

#### Cyberpunk UI Design Rules:

- **Use open-ended frames**: Left border only, no right border
- **UTF-8 icons**: ⚡⧗∞⬢⚙◆➜✓○
- **Box drawing**: `╔═╠╚║` (no `╗╣╝` right-side chars)
- **Color scheme**: Cyan frames, yellow highlights, green success, gray inactive

### Security Considerations

- **No automatic backdoors**: User creation is interactive, requires confirmation
- **Credentials displayed once**: User must save manually (no email/logging)
- **Passwordless sudo**: Admin accounts get `NOPASSWD:ALL` - change in production
- **SSH hardening**: Custom port, no root login, Fail2Ban protection
- **Dual-stack security**: Both IPv4 and IPv6 protected by Fail2Ban
- **External dependencies**: Downloads from GitHub and eggheads.org - verify sources
- **Root execution required**: Makes system-wide changes - review before running
- **Production use**: Change generated passwords after first login

### Dependencies

**From Debian Trixie repositories**:
- zsh, fzf (0.60.3+), eza, zoxide (no cargo compilation needed)
- caddy, php-fpm (replaced Apache2)
- Modern build tools: meson, ninja-build

**External downloads**:
- Eggdrop 1.8.4 from eggheads.org (SHA256 verified)
- Psotnic, KNB, update binaries from GitHub (via `${GITHUB_URL}`)
- Zinit from GitHub (installed globally)

### Future Improvements

Potential areas for enhancement:
- Automated testing suite
- Option to skip specific installation phases
- Configuration file for customizing task selection
- Support for other Debian-based distributions
- IPv6-only mode flag
- Alternative theme options for MOTD/progress bar
