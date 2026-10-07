# charon-bash

A small **custom** shell for SSH access to the **charon** server. Users connecting
on a dedicated SSH port land in `charon-bash` instead of a login shell. From
there they can run built-in commands, allowed system commands, or drop into a
regular `bash` (and come back with `exit`).

## Commands

| Command | Description |
|---|---|
| `help` | List built-in and system commands |
| `bash` | Start a regular bash shell, `exit` returns to charon-bash |
| `!<line>` | Run any command line through bash |
| `cd` | Change directory (`cd -` = previous) |
| `status` | Docker containers and their state |
| `info` | Uptime, memory, disk |
| `reload` | Re-read the command config |
| `version` | Show version |
| `exit` | Log out |

Any command listed in the config can be typed directly (pipes, redirects and
globs work), e.g. `docker ps | grep traefik`.

## Configuration

- `config/commands` – versioned list of allowed system commands
- `/etc/charon-bash/commands.local` – server-specific changes, not versioned;
  a line `-sudo` removes a command from the versioned list

The list is a convenience, **not a security boundary**: `bash` and `!` give
full shell access with the user's own permissions.

## Installation

```bash
sudo git clone https://github.com/<user>/charon-bash.git /opt/charon-bash
sudo /opt/charon-bash/install.sh
```

The installer symlinks `/usr/local/bin/charon-bash` to the repository,
creates `/etc/charon-bash/commands.local` and enables the update timer.

### SSH

In `/etc/ssh/sshd_config` listen on both ports and add at the **end** of the file:

```
Port 22
Port 2222

Match LocalPort 2222
    ForceCommand /usr/local/bin/charon-bash
    AllowTcpForwarding no
    AllowAgentForwarding no
    X11Forwarding no
    PermitTunnel no
```

Validate with `sudo sshd -t`, then restart sshd (on socket-activated Ubuntu:
`systemctl daemon-reload && systemctl restart ssh.socket`).

## Releases and automatic updates

The server deploys **only tagged releases** (`vX.Y.Z`); pushing to `main`
alone changes nothing. A systemd timer checks GitHub every 15 minutes, and the
new script must pass a syntax check before it is deployed.

To release:

1. Bump `VERSION` in `charon-bash` and update `CHANGELOG.md`
2. `git commit -am "Release v0.5.0"`
3. `git tag v0.5.0`
4. `git push --follow-tags`

On the server:

```bash
sudo systemctl start charon-bash-update.service   # update now
journalctl -u charon-bash-update.service          # update log
charon-bash --version
```
