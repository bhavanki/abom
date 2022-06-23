#!/usr/bin/env bash

set -e

source ../abom.bash

radio1=$(abom_make_radio "Autobot" 1)
radio2=$(abom_make_radio "Decepticon" 0)
checkbox1=$(abom_make_checkbox "Cold constructed")
textinput1=$(abom_make_text_input "Name" 40 "Genericon")
numberinput1=$(abom_make_number_input "Rank" 1 10 5)
select1=$(abom_make_select "Function" 0 "Warrior" "Scientist" "Logistics" "Demolitions" "Spy" "Leader")
button1=$(abom_make_button "Generate")

cursor=0
cursors=(false false false false false false)

reset_cursors() {
  for (( i = 0; i < ${#cursors[@]}; i++ )); do
    cursors[$i]=false
  done
}

build_content() {
  reset_cursors
  cursors[$cursor]=true

  echo "Build your robot:

$(abom_render_radio "$radio1" "${cursors[0]}")
$(abom_render_radio "$radio2" "false")

$(abom_render_checkbox "$checkbox1" "${cursors[1]}")

$(abom_render_text_input "$textinput1" "${cursors[2]}")

$(abom_render_number_input "$numberinput1" "${cursors[3]}")

$(abom_render_select "$select1" "${cursors[4]}")

$(abom_render_button "$button1" "${cursors[5]}")"
}

abom_init 14 "$(build_content)"

while true; do
  key=$(read_key)
  if [[ "$key" == "_tab" ]]; then
    cursor=$(( (cursor + 1) % 6 ))
  elif [[ "$key" == "_shift_tab" ]]; then
    cursor=$(( cursor - 1 ))
    if (( cursor < 0 )); then
      cursor=5
    fi
  else
    case $cursor in
      0)
        case "$key" in
          " ")
            radio1=$(abom_toggle_radio "$radio1")
            radio2=$(abom_toggle_radio "$radio2")
            ;;
        esac
        ;;
      1)
        case "$key" in
          " ")
            checkbox1=$(abom_toggle_checkbox "$checkbox1")
            ;;
        esac
        ;;
      2)
        textinput1=$(abom_modify_text_input "$textinput1" "$key")
        ;;
      3)
        numberinput1=$(abom_modify_number_input "$numberinput1" "$key")
        ;;
      4)
        select1=$(abom_modify_select "$select1" "$key")
        ;;
      5)
        break
    esac
  fi

  abom_render "$(build_content)"
done

spinner1=$(abom_make_spinner "Retrieving spark")
for (( i = 0; i < 10; i++ )); do
  abom_render "$(abom_render_spinner "$spinner1")"
  spinner1=$(abom_tick_spinner "$spinner1")
  sleep 0.2
done

progress1=$(abom_make_progress "20")
for (( i = 0; i < 10; i++ )); do
  abom_render "Implanting in protoform $(abom_render_progress "$progress1")"
  progress1=$(abom_set_percent_progress "$progress1" "$(( (i + 1) * 10 ))")
  sleep 0.2
done

abom_close

echo "Here is your robot."
echo
echo "Name: $(abom_get_content_text_input "$textinput1")"
if abom_is_selected_radio "$radio1"; then
  echo "Faction: Autobot"
else
  echo "Faction: Decepticon"
fi
echo "Rank: $(abom_get_content_number_input "$numberinput1")"
echo "Function: $(abom_get_selected_item_select "$select1")"
if abom_is_selected_checkbox "$checkbox1"; then
  echo "Cold constructed"
else
  echo "Forged"
fi
