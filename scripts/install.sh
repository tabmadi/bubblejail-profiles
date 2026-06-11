#!/usr/bin/env bash
#
# Install bubblejail profiles from this repository into the user's
# bubblejail profiles directory (~/.config/bubblejail/profiles).
#
# Usage:
#   ./scripts/install.sh                 # install all profiles
#   ./scripts/install.sh firefox tor     # install specific profiles
#   ./scripts/install.sh --copy          # copy instead of symlink
#   ./scripts/install.sh --list          # list available profiles

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILES_DIR="${REPO_ROOT}/profiles"
DEST_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/bubblejail/profiles"

mode="link"
names=()

for arg in "$@"; do
    case "${arg}" in
        --copy)
            mode="copy"
            ;;
        --list)
            mode="list"
            ;;
        -h|--help)
            grep '^#' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            names+=("${arg}")
            ;;
    esac
done

mapfile -t available < <(find "${PROFILES_DIR}" -maxdepth 1 -type f -name '*.toml' -printf '%f\n' | sed 's/\.toml$//' | sort)

if [[ "${mode}" == "list" ]]; then
    printf '%s\n' "${available[@]}"
    exit 0
fi

if [[ ${#names[@]} -eq 0 ]]; then
    names=("${available[@]}")
fi

mkdir -p "${DEST_DIR}"

for name in "${names[@]}"; do
    src="${PROFILES_DIR}/${name}.toml"
    if [[ ! -f "${src}" ]]; then
        echo "warning: no profile named '${name}' found, skipping" >&2
        continue
    fi

    dest="${DEST_DIR}/${name}.toml"

    if [[ "${mode}" == "copy" ]]; then
        cp -f "${src}" "${dest}"
        echo "copied   ${name} -> ${dest}"
    else
        ln -sf "${src}" "${dest}"
        echo "linked   ${name} -> ${dest}"
    fi
done
