#!/usr/bin/env bash
# Check GitHub for a newer release tag (vX.Y.Z) and deploy it.
# Runs as root from charon-bash-update.timer; can also be run by hand.
#
# Only tagged releases are deployed - pushing to main alone changes nothing.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
cd "$REPO_DIR"

git fetch --quiet --tags --force --prune origin

latest="$(git tag -l 'v*' --sort=-v:refname | head -n1)"
if [[ -z "$latest" ]]; then
    echo "No release tags (v*) found, nothing to deploy."
    exit 0
fi

current="$(git describe --tags --exact-match HEAD 2>/dev/null || echo none)"
if [[ "$latest" == "$current" ]]; then
    exit 0
fi

# Sanity check before switching: the new script must at least parse
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
git show "$latest:charon-bash" > "$tmp"
if ! python3 -c 'import ast, sys; ast.parse(open(sys.argv[1]).read())' "$tmp"; then
    echo "Release $latest failed the syntax check, staying on $current." >&2
    exit 1
fi

echo "Updating charon-bash: $current -> $latest"
git -c advice.detachedHead=false checkout --quiet --force --detach "$latest"

# Run the installer from the NEW release (units, symlink, config may have changed)
exec "$REPO_DIR/install.sh" --from-update
