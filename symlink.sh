#!/usr/bin/env bash
set -euo pipefail

fail() {
    printf 'Error: %s\n' "$*" >&2
    exit 1
}

for tool in jq realpath ln; do
    command -v "$tool" >/dev/null 2>&1 || fail "Required tool not found: $tool"
done

script_dir="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
data_home="${XDG_DATA_HOME:-${HOME:?HOME or XDG_DATA_HOME must be set}/.local/share}"
[[ "$data_home" = /* ]] || fail "XDG_DATA_HOME must be an absolute path."
package_root="$data_home/plasma/plasmoids"

sources=()
destinations=()
for project in aqua-glass-dock aqua-global-menu; do
    source="$(realpath -e -- "$script_dir/$project/package")"
    [[ -d "$source" && -f "$source/contents/ui/main.qml" ]] ||
        fail "Missing package directory or QML entry point: $source"
    id="$(jq -er '
        select(.KPackageStructure == "Plasma/Applet")
        | .KPlugin.Id
        | select(type == "string")
        | select(test("^[A-Za-z0-9][A-Za-z0-9._-]*$"))
    ' "$source/metadata.json")" || fail "Invalid applet metadata: $source/metadata.json"
    destination="$package_root/$id"
    for existing in "${destinations[@]}"; do
        [[ "$destination" != "$existing" ]] || fail "Duplicate plugin ID: $id"
    done
    sources+=("$source")
    destinations+=("$destination")
done

mkdir -p -- "$package_root"
resolved_package_root="$(realpath -e -- "$package_root")"
case "$resolved_package_root/" in
    "$script_dir/"*) fail "Refusing to create installation links inside the project." ;;
esac

# Check all destinations before creating either link.
for i in "${!sources[@]}"; do
    destination="${destinations[$i]}"
    if [[ -L "$destination" ]]; then
        resolved_target="$(realpath -m -- "$destination")"
        [[ "$resolved_target" = "${sources[$i]}" ]] ||
            fail "Refusing to replace conflicting symlink: $destination"
    elif [[ -e "$destination" ]]; then
        fail "Refusing to replace existing entry: $destination"
    fi
done

for i in "${!sources[@]}"; do
    destination="${destinations[$i]}"
    if [[ -L "$destination" ]]; then
        printf 'Already linked: %s\n' "$destination"
    else
        # -T prevents following an existing destination as a directory; no -f.
        ln -sT -- "${sources[$i]}" "$destination"
        printf 'Linked: %s -> %s\n' "$destination" "${sources[$i]}"
    fi
done
