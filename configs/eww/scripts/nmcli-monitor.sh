#!/usr/bin/env bash

get_type() {
    nmcli -t con show --active | awk -F ':' '{print $3; exit}'
}

get_type
nmcli monitor | while read -r line; do
  get_type
done
