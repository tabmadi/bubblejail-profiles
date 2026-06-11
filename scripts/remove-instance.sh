#!/usr/bin/env bash
#
# Remove a bubblejail instance created from one of this repository's
# profiles, including its data directory, desktop entry, and runtime
# lock/socket directory.
#
# Usage:
#   ./scripts/remove-instance.sh <instance-name>
#   ./scripts/remove-instance.sh --list

set -euo pipefail

DATA_DIR="${XDG_DATA_HOME:-${HOME}/.local/share}/bubblejail/instances"
APPLICATIONS_DIR="${XDG_DATA_HOME:-${HOME}/.local/share}/applications"
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/bubblejail"

if [[ $# -eq 0 || "${1}" == "-h" || "${1}" == "--help" ]]; then
    grep '^#' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
    exit 0
fi

if [[ "${1}" == "--list" ]]; then
    find "${DATA_DIR}" -maxdepth 1 -mindepth 1 -type d -printf '%f\n' 2>/dev/null | sort
    exit 0
fi

name="${1}"
instance_dir="${DATA_DIR}/${name}"
runtime_instance_dir="${RUNTIME_DIR}/${name}"

if [[ ! -d "${instance_dir}" ]]; then
    echo "error: no instance named '${name}' found in ${DATA_DIR}" >&2
    exit 1
fi

if [[ -d "${runtime_instance_dir}" ]]; then
    echo "error: instance '${name}' appears to be running (${runtime_instance_dir} exists)" >&2
    echo "stop it first with: bubblejail stop ${name}" >&2
    exit 1
fi

# Find desktop entry referencing this instance, if any
desktop_entry=""
metadata_file="${instance_dir}/metadata_v1.toml"
if [[ -f "${metadata_file}" ]]; then
    desktop_entry_name="$(grep -oP '(?<=desktop_entry_name = ")[^"]*' "${metadata_file}" || true)"
    if [[ -n "${desktop_entry_name}" && -f "${APPLICATIONS_DIR}/${desktop_entry_name}" ]]; then
        desktop_entry="${APPLICATIONS_DIR}/${desktop_entry_name}"
    fi
fi
if [[ -z "${desktop_entry}" && -f "${APPLICATIONS_DIR}/bubble_${name}.desktop" ]]; then
    desktop_entry="${APPLICATIONS_DIR}/bubble_${name}.desktop"
fi

rm -rf "${instance_dir}"
echo "removed  ${instance_dir}"

if [[ -n "${desktop_entry}" ]]; then
    rm -f "${desktop_entry}"
    echo "removed  ${desktop_entry}"

    if command -v update-desktop-database &>/dev/null; then
        update-desktop-database "${APPLICATIONS_DIR}"
    fi
fi

if [[ -d "${RUNTIME_DIR}/${name}" ]]; then
    rm -rf "${RUNTIME_DIR}/${name}"
    echo "removed  ${RUNTIME_DIR}/${name}"
fi
