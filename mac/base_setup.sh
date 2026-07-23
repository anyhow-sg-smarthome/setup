#!/usr/bin/env bash

set -euo pipefail

step () {
    printf "🔹 $1 \n"
}

success () {
    printf "\n🍺 $1 \n\n"
}

clone_plugin() {
    local repo="$1"
    local target="$2"

    if [ ! -d "$target" ]; then
        git clone "$repo" "$target"
    else
        echo "Plugin already exists: $target"
    fi
}
