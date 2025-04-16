#!/usr/bin/env bash

retrieve_focused() {
    # niri msg -j workspaces | jq -Mc '.=sort_by(.id) | if .[-1].is_focused then . else .[0:-1] end'
    niri msg -j focused-window | jaq -Mcr '.title? // ""'
}

retrieve_focused
niri msg event-stream | while read -r line; do
    if [[ "$line" == "Window"* ]]; then
        retrieve_focused
    fi
done
