#!/bin/bash

# Check if source and destination are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <source> <destination>"
    exit 1
fi

SRC="$1"
DEST="$2"

# Ensure source exists
if [ ! -d "$SRC" ]; then
    echo "Error: Source does not exist."
    exit 1
fi

# Try moving normally
mv -f "$SRC" "$DEST" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "Successfully moved $SRC to $DEST."
    exit 0
fi

# If move fails, ask for sudo permission using GUI
if [[ "$OSTYPE" == "darwin"* ]]; then
    osascript -e "do shell script 'sudo rm -rf "$DEST" && sudo -S mv "$SRC" "$DEST"' with administrator privileges"
elif command -v pkexec &>/dev/null; then
    pkexec bash -c "rm -rf '$DEST' && mv -f '$SRC' '$DEST'"
elif command -v gksudo &>/dev/null; then
    gksudo -- bash -c "rm -rf '$DEST' && mv -f '$SRC' '$DEST'"
elif command -v kdesudo &>/dev/null; then
    kdesudo -- bash -c "rm -rf '$DEST' && mv -f '$SRC' '$DEST'"
elif command -v zenity &>/dev/null; then
    PASSWORD=$(zenity --password --title="Authentication Required")
    echo "$PASSWORD" | sudo -S rm -rf "$DEST" && mv "$SRC" "$DEST"
elif command -v kdialog &>/dev/null; then
    PASSWORD=$(kdialog --password "Authentication Required")
    echo "$PASSWORD" | sudo -S rm -rf "$DEST" && mv "$SRC" "$DEST"
else
    echo "No suitable authentication method found. Please run manually: sudo mv -f '$SRC' '$DEST'"
    exit 1
fi

if [ $? -eq 0 ]; then
    echo "Successfully moved $SRC to $DEST with sudo."
else
    echo "Failed to move $SRC to $DEST."
    exit 1
fi
