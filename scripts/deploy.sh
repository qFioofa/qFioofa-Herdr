#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/herdr"
CONFIG="$CONFIG_DIR/config.toml"
INSTALL_INTEGRATIONS=1

usage() {
	cat <<'EOF'
Usage: scripts/deploy.sh [--no-integrations]

Installs src/config.toml into ~/.config/herdr/config.toml, validates it,
reloads a running Herdr server, and installs integrations for agents that
are present in PATH.

Options:
  --no-integrations  Skip herdr integration install
  -h, --help         Show this help
EOF
}

for arg in "$@"; do
	case "$arg" in
		--no-integrations) INSTALL_INTEGRATIONS=0 ;;
		-h | --help)
			usage
			exit 0
			;;
		*)
			echo "Unknown option: $arg" >&2
			usage >&2
			exit 2
			;;
	esac
done

if ! command -v herdr >/dev/null 2>&1; then
	echo "herdr is not in PATH" >&2
	exit 1
fi

mkdir -p "$CONFIG_DIR"

if [ -f "$CONFIG" ]; then
	backup="$CONFIG.bak.$(date +%Y%m%d-%H%M%S)"
	cp -a "$CONFIG" "$backup"
	echo "Backup: $backup"
fi

install -m 0644 "$ROOT/src/config.toml" "$CONFIG"
echo "Installed: $CONFIG"

HERDR_CONFIG_PATH="$CONFIG" herdr config check

if herdr status server 2>/dev/null | grep -q '^status: running'; then
	herdr server reload-config
	echo "Reloaded running Herdr server"
else
	echo "Herdr server is not running; config will load on next launch"
fi

if [ "$INSTALL_INTEGRATIONS" -eq 1 ]; then
	for agent in opencode claude codex; do
		if command -v "$agent" >/dev/null 2>&1; then
			if herdr integration install "$agent" >/dev/null 2>&1; then
				echo "Installed integration: $agent"
			else
				echo "Integration install failed: $agent" >&2
			fi
		fi
	done
fi
