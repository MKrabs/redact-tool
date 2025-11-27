#!/usr/bin/env bash
set -e

# Paths
LIBDIR="/usr/local/share/redact"
BINDIR="/usr/local/bin"
MAIN_SCRIPT="redact"

echo "Uninstalling redact..."

# 1️⃣ Remove main script safely
if [[ -f "$BINDIR/$MAIN_SCRIPT" ]]; then
    echo "Removing $BINDIR/$MAIN_SCRIPT"
    sudo rm "$BINDIR/$MAIN_SCRIPT"
else
    echo "Main script not found, skipping."
fi

# 2️⃣ Remove library folder safely
if [[ -d "$LIBDIR" ]]; then
    echo "Removing $LIBDIR"
    sudo rm -rf "$LIBDIR"
else
    echo "Library folder not found, skipping."
fi

echo "Redact uninstalled. User profiles are not affected."
