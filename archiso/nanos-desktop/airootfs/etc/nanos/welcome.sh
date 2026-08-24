#!/usr/bin/env bash
# Runs once on first login, unless ~/.nanos-welcomed already exists.
# Wired up via /etc/profile.d/nanos-welcome.sh — see that file for how
# this gets triggered automatically at login.

MARKER="$HOME/.nanos-welcomed"
if [ -f "$MARKER" ]; then
    return 0 2>/dev/null || exit 0
fi

echo ""
echo "=================================="
echo "   Welcome to nanOS"
echo "=================================="
echo ""
echo "Choose a shell to work with:"
echo "  1) bash"
echo "  2) zsh"
read -rp "> " shell_choice

case "$shell_choice" in
    2)
        if [ "$(id -u)" -eq 0 ]; then
            chsh -s /usr/bin/zsh "$USER"
        else
            sudo chsh -s /usr/bin/zsh "$USER"
        fi
        echo "zsh selected. This takes effect on next login."
        echo ""
        echo "Want a customized terminal setup? nanOS recommends Oh My Zsh"
        echo "for a solid set of themes, plugins, and sane defaults:"
        echo "  https://ohmyz.sh/"
        echo ""
        read -rp "Install Oh My Zsh now? [y/N] " omz_choice
        if [[ "$omz_choice" =~ ^[Yy]$ ]]; then
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
            echo "Oh My Zsh installed. Log back in as zsh to see it."
        else
            echo "Skipped. You can install it later from https://ohmyz.sh/"
        fi
        ;;
    *)
        echo "bash selected (default)."
        ;;
esac

echo ""
echo "Run 'nanctl list' to see available presets (browser, devtools, cluster)."
echo "Run 'nanctl status' to see system info."
echo ""

touch "$MARKER"
