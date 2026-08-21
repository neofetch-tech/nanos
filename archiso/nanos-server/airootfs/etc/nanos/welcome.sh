#!/usr/bin/env bash
# Runs once on first login, unless ~/.nanos-welcomed already exists
MARKER="$HOME/.nanos-welcomed"
if [ -f "$MARKER" ]; then
    return 0 2>/dev/null || exit 0
fi

echo "Welcome to nanOS."
echo ""
echo "Choose a shell to work with:"
echo "  1) bash"
echo "  2) zsh"
read -rp "> " choice

case "$choice" in
    2)
        sudo chsh -s /usr/bin/zsh "$USER"
        echo "zsh selected. This takes effect on next login."
        ;;
    *)
        echo "bash selected (default)."
        ;;
esac

touch "$MARKER"
