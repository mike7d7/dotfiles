#!/usr/bin/env bash
current_monitors=()
mapfile -t current_monitors < <( niri msg -j outputs | jq -Mcr '[ map(select(.current_mode != null))[] | .model ] | sort[]' )

check_monitors() {
  id_number=0
  for monitor in "${current_monitors[@]}"
  do
    eww open statusbar --screen "$monitor" --id "$id_number"
    id_number+=1
  done
}

check_monitors
niri msg event-stream | while read -r line; do
  if [[ "$line" == "Workspaces changed:"* ]]; then
    new_monitors=()
    mapfile -t new_monitors < <( niri msg -j outputs | jq -Mcr '[ map(select(.current_mode != null))[] | .model ] | sort[]' )

    if [[ "${current_monitors[*]}" != "${new_monitors[*]}" ]]; then
        # echo "reloading"
        # echo "${current_monitors[*]}"
        # echo "${new_monitors[*]}"
        current_monitors=("${new_monitors[@]}")
        check_monitors
    fi
  fi
done
