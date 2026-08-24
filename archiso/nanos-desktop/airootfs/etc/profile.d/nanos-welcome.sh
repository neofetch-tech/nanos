#!/bin/sh
# Auto-runs the nanOS welcome script on every login shell.
# /etc/profile.d/ is sourced by /etc/profile for every login shell,
# regardless of bash/zsh/sh — this is the standard Linux mechanism for
# "run this at login", so we don't need to touch .bashrc/.zshrc directly.

if [ -f /etc/nanos/welcome.sh ]; then
    . /etc/nanos/welcome.sh
fi
