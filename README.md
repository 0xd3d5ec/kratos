# Kratos

Kratos is a Debian/Kali bootstrap repo focused on terminal productivity and machine setup.

## Kalix (`kratos.sh`)

Kalix bootstraps a Debian/Kali environment by:

- installing base packages in a single transaction with retries
- setting up Zsh + Oh-My-Zsh + kali-like two-line prompt
- configuring tmux with managed logging/default/clipboard blocks
- enabling zoxide and shell quality-of-life defaults
- writing timestamped backups and a run log for traceability

## Requirements

- Debian or Kali (or Debian-like distro)
- non-root user
- `sudo` access
- network access for apt and git clones

## Quick Start

```bash
chmod +x kratos.sh
./kratos.sh
```

## CLI Options

```text
Usage: ./kratos.sh [options]

General options:
  --dry-run               Print actions without changing files
  --non-interactive       Disable prompts (safe defaults)
  --yes                   Answer yes to prompts
  --profile NAME          Package profile: default|minimal|dev|pentest|desktop
  --uninstall             Remove Kalix-managed config blocks

Scope options:
  --skip-zsh              Skip Zsh and Oh-My-Zsh setup
  --skip-tmux             Skip tmux setup
  --only-packages         Install packages only
  --only-shell            Configure shell/tmux only

Shell options:
  --no-chsh               Do not change default shell
  --chsh                  Force changing default shell to zsh
  --tmux-autostart MODE   Mode: yes|no|ask

Other options:
  -h, --help              Show this help message
```

## Package Profiles

- `default`: base package set only
- `minimal`: same as default, no extras
- `dev`: adds `build-essential jq ripgrep fd-find bat tree`
- `pentest`: adds `nmap sqlmap gobuster wfuzz`
- `desktop`: adds `xfce4 xfce4-goodies`

## What Kalix Manages

Kalix writes and updates managed blocks with markers in:

- `~/.zshrc`
  - `KALIX_CORE`
  - `KALIX_ZOXIDE`
  - `KALIX_ALIASES`
  - `KALIX_TMUX_AUTOSTART` (optional)
- `~/.tmux.conf.local`
  - `KALIX_LOGGING`
  - `KALIX_DEFAULTS`
  - `KALIX_CLIPBOARD`

These markers make reruns idempotent and allow safe uninstall of Kalix-managed blocks.

## Backups and Logs

- Backups are timestamped, for example: `~/.zshrc.kalix.bak.20260219-031500`
- Run logs are stored in: `~/.kalix/logs/`
- A summary is printed at the end of each run (installed, changed, skipped, errors)

## Common Examples

Install everything with dev profile:

```bash
./kratos.sh --profile dev
```

Preview changes only:

```bash
./kratos.sh --dry-run
```

Install packages only (no shell or tmux config):

```bash
./kratos.sh --only-packages
```

Configure shell/tmux only (no apt install):

```bash
./kratos.sh --only-shell
```

Non-interactive mode for automation:

```bash
./kratos.sh --non-interactive --yes --tmux-autostart no --no-chsh
```

Remove only Kalix-managed config blocks:

```bash
./kratos.sh --uninstall
```

## Notes

- Kalix avoids running as root and uses `sudo` when needed.
- In non-interactive mode, shell change is disabled by default.
- `--only-packages` and `--only-shell` are mutually exclusive.
