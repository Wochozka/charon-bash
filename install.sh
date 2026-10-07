#!/usr/bin/env bash
# Install or refresh charon-bash on this server.
# Idempotent - safe to run repeatedly. Must run as root.
#
#   sudo ./install.sh                 first install / manual refresh
#   install.sh --from-update          called by update.sh after a new release
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
BIN=/usr/local/bin/charon-bash
CONF_DIR=/etc/charon-bash
LOCAL_CONF="$CONF_DIR/commands.local"
UNIT_DIR=/etc/systemd/system

if [[ $EUID -ne 0 ]]; then
    echo "Run as root: sudo $0" >&2
    exit 1
fi

for dep in python3 git; do
    command -v "$dep" >/dev/null || { echo "Missing dependency: $dep" >&2; exit 1; }
done

# Executable + symlink: a new release is live as soon as the repo is updated
chmod 755 "$REPO_DIR/charon-bash" "$REPO_DIR/install.sh" "$REPO_DIR/update.sh"
ln -sfn "$REPO_DIR/charon-bash" "$BIN"

# Local, non-versioned config - created once, never overwritten
mkdir -p "$CONF_DIR"
if [[ ! -e "$LOCAL_CONF" ]]; then
    cat > "$LOCAL_CONF" <<'CONF'
# Server-specific changes to config/commands from the repository.
# One command per line; prefix with '-' to remove a command, e.g.:
#   ncdu
#   -sudo
CONF
fi

# systemd units for automatic updates
for unit in "$REPO_DIR"/systemd/*; do
    sed "s|@REPO_DIR@|$REPO_DIR|g" "$unit" > "$UNIT_DIR/$(basename "$unit")"
done
systemctl daemon-reload
systemctl enable --quiet --now charon-bash-update.timer

echo "charon-bash $("$BIN" --version | awk '{print $2}') installed from $REPO_DIR"

# On a manual install, switch to the latest release right away
if [[ "${1:-}" != "--from-update" ]]; then
    "$REPO_DIR/update.sh"
fi
