#!/usr/bin/env bash
set -e

# Paths
LIBDIR="/usr/local/share/redact"
BINDIR="/usr/local/bin"
MAIN_SCRIPT="redact"
MODULES=("core.sh" "profile.sh" "replacer.sh" "util.sh" "completion.sh")

echo "Installing redact..."

# 1️⃣ Create library folder if missing
sudo mkdir -p "$LIBDIR"

# 2️⃣ Copy module files safely from lib/
for f in "${MODULES[@]}"; do
    SRC="lib/$f"
    if [[ ! -f "$SRC" ]]; then
        echo "Warning: $SRC not found — skipping."
        continue
    fi

    if [[ ! -f "$LIBDIR/$f" ]] || ! cmp -s "$SRC" "$LIBDIR/$f"; then
        echo "Copying $SRC → $LIBDIR/"
        sudo cp "$SRC" "$LIBDIR/"
    else
        echo "$f already up-to-date."
    fi
done

# 3️⃣ Copy main executable from bin/
SRC_MAIN="bin/$MAIN_SCRIPT"
if [[ ! -f "$SRC_MAIN" ]]; then
    echo "Error: Main script '$SRC_MAIN' not found. Aborting."
    exit 1
fi

if [[ ! -f "$BINDIR/$MAIN_SCRIPT" ]] || ! cmp -s "$SRC_MAIN" "$BINDIR/$MAIN_SCRIPT"; then
    echo "Copying $SRC_MAIN → $BINDIR/"
    sudo cp "$SRC_MAIN" "$BINDIR/"
fi

# 4️⃣ Ensure executable
sudo chmod +x "$BINDIR/$MAIN_SCRIPT"

echo "Installation complete!"
echo "Redact is ready to use: $BINDIR/$MAIN_SCRIPT"

