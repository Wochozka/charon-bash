# Changelog

## v0.5.0
- Restart after update

## v0.4.6
- Remove Welcome

## v0.4.5
- Hotfix

## v0.4.4
- Add Welcome

## v0.4.3
- Hotfix release

## v0.4.2
- Broken code

## v0.4.1
- Add update internal command"

## v0.4.0
- System command list moved to `config/commands` (versioned) and
  `/etc/charon-bash/commands.local` (server-specific, `-cmd` removes a command)
- New built-ins: `reload`, `version`; `charon-bash --version`
- Installer and automatic updates from GitHub release tags (systemd timer)

## v0.3
- System commands run directly via an allowlist, `!` prefix runs anything through bash
- Built-in `cd`, current directory in the prompt, exit codes shown

## v0.2
- `vi` command, tab completion of paths

## v0.1
- Initial version: `bash`, `status`, `info`, `clear`, `exit`
