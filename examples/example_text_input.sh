#!/usr/bin/env bash

set -e

source ../abom.bash

text_input=$(abom_make_text_input "Favorite robot:" 40 "Optimus Prime")

build_content() {
  echo "$(abom_render_text_input "$text_input" "false")"
}

abom_init 3 "$(build_content)"

while true; do
  key=$(read_key)
  if [[ $key == "_nl" ]]; then
    break
  fi
  text_input=$(abom_modify_text_input "$text_input" "$key")
  abom_render "$(build_content)"
done

abom_close

echo "Your favorite robot is $(abom_get_content_text_input "$text_input")"
