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

# 2️⃣ Copy module files safely
for f in "${MODULES[@]}"; do
    if [[ ! -f "$LIBDIR/$f" ]] || ! cmp -s "$f" "$LIBDIR/$f"; then
        echo "Copying $f → $LIBDIR/"
        sudo cp "$f" "$LIBDIR/"
    else
        echo "$f already up-to-date."
    fi
done

# 3️⃣ Copy main executable
if [[ ! -f "$BINDIR/$MAIN_SCRIPT" ]] || ! cmp -s "$MAIN_SCRIPT" "$BINDIR/$MAIN_SCRIPT"; then
    echo "Copying $MAIN_SCRIPT → $BINDIR/"
    sudo cp "$MAIN_SCRIPT" "$BINDIR/"
fi

# 4️⃣ Ensure executable
sudo chmod +x "$BINDIR/$MAIN_SCRIPT"

echo "Installation complete!"
echo "Redact is ready to use: $BINDIR/$MAIN_SCRIPT"
