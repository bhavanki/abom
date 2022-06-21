# shellcheck disable=SC2155

abom_indent() {
  local content=$1
  local indent=${2:-0}

  if (( indent > 0 )); then
    printf "%*s" "$indent" ""
  fi
  printf "%s" "$content"
}

abom_color() {
  local content=$1
  local color=$2

  local cc
  case $color in
    black)
      cc='0;30'
      ;;
    red)
      cc='0;31'
      ;;
    green)
      cc='0;32'
      ;;
    yellow)
      cc='0;33'
      ;;
    blue)
      cc='0;34'
      ;;
    magenta)
      cc='0;35'
      ;;
    cyan)
      cc='0;36'
      ;;
    white)
      cc='0;37'
      ;;
    bright_black)
      cc='1;30'
      ;;
    bright_red)
      cc='1;31'
      ;;
    bright_green)
      cc="1;32"
      ;;
    bright_yellow)
      cc='1;33'
      ;;
    bright_blue)
      cc='1;34'
      ;;
    bright_magenta)
      cc='1;35'
      ;;
    bright_cyan)
      cc='1;36'
      ;;
    bright_white)
      cc='1;37'
      ;;
    *)
      cc='0'
      ;;
  esac

  printf '\e[%sm%s' "$cc" "$content"
}

abom_default() {
  printf '\e[0m'
}

_abom_get_cursor() {
  local show=${1:-false}

  if [[ $show == "true" || $show == 1 ]]; then
    echo ">"
  else
    echo " "
  fi
}

abom_make_radio() {
  # label=x;selected=x
  local label=$1
  local selected=${2:-0}
  make_struct label "$label" selected "$selected"
}

abom_toggle_radio() {
  local el=$1
  local selected=$(struct_get "$el" selected)
  selected=$(( (selected + 1) % 2 ))
  struct_set "$el" selected "$selected"
}

abom_render_radio() {
  local el=$1
  local show_cursor=${2:-false}

  local cursor=$(_abom_get_cursor "$show_cursor")
  local icon=" "
  local selected=$(struct_get "$el" selected)
  if [[ $selected == 1 ]]; then
    icon="*"
  fi
  local label=$(struct_get "$el" label)
  printf "%s (%s) %s" "$cursor" "$icon" "$label"
}

abom_make_checkbox() {
  # label=x;selected=x
  local label=$1
  local selected=${2:-0}
  make_struct label "$label" selected "$selected"
}

abom_toggle_checkbox() {
  local el=$1
  local selected=$(struct_get "$el" selected)
  selected=$(( (selected + 1) % 2 ))
  struct_set "$el" selected "$selected"
}

abom_render_checkbox() {
  local el=$1
  local show_cursor=${3:-false}

  local cursor=$(_abom_get_cursor "$show_cursor")
  local icon=" "
  local selected=$(struct_get "$el" selected)
  if [[ $selected == 1 ]]; then
    icon="x"
  fi
  local label=$(struct_get "$el" label)
  printf "%s [%s] %s" "$cursor" "$icon" "$label"
}

abom_make_text_input() {
  # label=x;len=x;content=x
  local label=$1
  local len=$2
  local content=${3:-}
  make_struct label "$label" len "$len" content "$content"
}

abom_modify_text_input() {
  local el=$1
  local key=$2
  local content=$(struct_get "$el" content)
  local len=$(struct_get "$el" len)
  local contentlen=${#content}
  local newcontent=$content
  case $key in
    _*)
      case $key in
        _bs)
          if (( contentlen > 0 )); then
            newlen=$((contentlen - 1))
            newcontent="${content:0:$newlen}"
          fi
          ;;
        _)
          if (( contentlen < len )); then
            newcontent="${content}_"
          fi
          ;;
        *)
          ;;
      esac
      ;;
    *)
      if (( contentlen < len )); then
        newcontent="${content}${key}"
      fi
      ;;
  esac

  struct_set "$el" content "$newcontent"
}

abom_render_text_input() {
  local el=$1
  local show_cursor=${2:-false}

  local cursor=$(_abom_get_cursor "$show_cursor")
  local len=$(struct_get "$el" len)
  local content=$(struct_get "$el" content)
  local num_blanks=$(( len - ${#content} ))
  local blanks=$(printf "%*s" "$num_blanks" "")
  blanks=${blanks// /_}
  local label=$(struct_get "$el" label)
  printf "%s %s %s%s" "$cursor" "$label" "$content" "$blanks"
}

abom_make_select() {
  # label=x;selected=x;width=x;len=x;c000=x;c001=x;...
  local label=$1
  local selected=$2
  shift 2
  local choices=()
  local width=0
  local i=0
  while [[ $# != 0 ]]; do
    local key=$(printf "c%03d" "$i")
    choices+=( "$key" "$1" )
    i=$(( i + 1 ))
    if (( "${#1}" > width )); then
      width=${#1}
    fi
    shift
  done
  make_struct label "$label" selected "$selected" width "$width" len "$i" "${choices[@]}"
}

abom_modify_select() {
  local el=$1
  local key=$2

  local selected=$(struct_get "$el" selected)
  if [[ $key == "_up" ]]; then
    if (( selected > 0 )); then
      selected=$(( selected - 1 ))
    fi
  elif [[ $key == "_down" ]]; then
    len=$(struct_get "$el" len)
    if (( selected < len - 1 )); then
      selected=$(( selected + 1 ))
    fi
  fi

  struct_set "$el" selected "$selected"
}

abom_render_select() {
  local el=$1
  local show_cursor=${2:-false}

  local cursor=$(_abom_get_cursor "$show_cursor")
  local itemkey=$(printf "c%03d" "$(struct_get "$el" selected)")
  local item=$(struct_get "$el" "$itemkey")

  local label=$(struct_get "$el" label)
  local width=$(struct_get "$el" width)
  printf "%s %s <%${width}s>" "$cursor" "$label" "$item"
}

abom_make_spinner() {
  # label=x;val=x
  local label=$1
  local val=${2:-0}
  make_struct label "$label" val "$val"
}

abom_tick_spinner() {
  local el=$1
  local val=$(struct_get "$el" val)
  val=$(( (val + 1) % 8 ))
  struct_set "$el" val "$val"
}

abom_render_spinner() {
  local el=$1
  local label=$(struct_get "$el" label)
  local val=$(struct_get "$el" val)

  case $val in
    0)
      icon=⠁
      ;;
    1)
      icon=⠂
      ;;
    2)
      icon=⠄
      ;;
    3)
      icon=⡀
      ;;
    4)
      icon=⢀
      ;;
    5)
      icon=⠠
      ;;
    6)
      icon=⠐
      ;;
    *)
      icon=⠈
      ;;
  esac

  printf "%s %s" "$icon" "$label"
}

abom_make_progress() {
  # len=x;pct=x
  local len=$1
  local pct=${2:-0}
  make_struct len "$len" pct "$pct"
}

abom_set_percent_progress() {
  local el=$1
  local pct=$2
  if (( pct < 0 )); then
    pct=0
  elif (( pct > 100 )); then
    pct=100
  fi

  struct_set "$el" pct "$pct"
}

abom_render_progress() {
  local el=$1
  local len=$(struct_get "$el" len)
  local pct=$(struct_get "$el" pct)

  local bar_len=$(( pct * len / 100 ))
  for (( i = 0; i < len; i++ )); do
    if (( i < bar_len )); then
      printf '█'
    else
      printf ' '
    fi
  done
}
