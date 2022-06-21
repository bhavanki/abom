#!/usr/bin/env bash

set -e

source ../abom.bash

spinner=$(abom_make_spinner "Waiting 10 seconds...")

abom_init 1 ""

for (( val = 0; val < 20; val++ )); do
  spinner=$(abom_tick_spinner "$spinner")
  content="$(abom_render_spinner "$spinner")"
  abom_render "$content"
  sleep 0.5
done

abom_close

echo "Done!"
