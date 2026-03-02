#!/usr/bin/env bash
# Tmux smooth-scroll plugin initialization
source "$(dirname "$0")/config.sh"

MODE_KEYS="$(tmux show-option -gwq mode-keys)"
TABLE="copy-mode-vi"
[ "$MODE_KEYS" = "emacs" ] && TABLE="copy-mode"

# Find keys bound to scroll commands and rebind
tmux list-keys -T "$TABLE" | while IFS= read -r line; do
    # Skip mouse wheel events if explicitly disabled
    if [ "$(config__mouse_scroll)" = "false" ]; then
        case "$line" in
            *Wheel*) continue ;;
        esac
    fi
    
    case "$line" in
        # Match default tmux scroll bindings
        *send-keys*scroll-up)       params="up normal" ;;
        *send-keys*scroll-down)     params="down normal" ;;
        *send-keys*halfpage-up)     params="up halfpage" ;;
        *send-keys*halfpage-down)   params="down halfpage" ;;
        *send-keys*page-up)         params="up fullpage" ;;
        *send-keys*page-down)       params="down fullpage" ;;
        # Match our own bindings (for re-initialization after config reload)
        *scroll.sh*up*normal*)      params="up normal" ;;
        *scroll.sh*down*normal*)    params="down normal" ;;
        *scroll.sh*up*halfpage*)    params="up halfpage" ;;
        *scroll.sh*down*halfpage*)  params="down halfpage" ;;
        *scroll.sh*up*fullpage*)    params="up fullpage" ;;
        *scroll.sh*down*fullpage*)  params="down fullpage" ;;
        *) continue ;;
    esac
    
    key=$(echo "$line" | awk '{print $4}')
    [ -n "$key" ] && tmux bind-key -T "$TABLE" "$key" run-shell -b "$SRC_DIR/scroll.sh $params"
done
