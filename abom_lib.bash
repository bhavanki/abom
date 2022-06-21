get_term_size() {
  shopt -s checkwinsize; (:;:)
}

trap 'get_term_size' WINCH

hide_cursor() {
  printf '\e[?25l'
}

show_cursor() {
  printf '\e[?25h'
}

get_cursor_pos() {
  local pos
  # shellcheck disable=SC2034
  read -p $'\e[6n' -r -s -d R pos
  # keysmash protection
  while [[ ${pos:0:1} != $'\e' ]]; do
    pos=${pos:1}
  done
  local len=$((${#pos} - 2))
  echo "${pos:2:$len}"
}

get_line_from_pos() {
  local pos=$1
  echo "${pos%%;*}"
}

get_column_from_pos() {
  local pos=$1
  echo "${pos##*;}"
}

# shellcheck disable=SC2120
prev_line_start() {
  local num=${1:-1}
  printf '\e[%dF' "$num"
}

# shellcheck disable=SC2120
next_line_start() {
  local num=${1:-1}
  printf '\e[%dE' "$num"
}

# shellcheck disable=SC2120
prev_line() {
  local num=${1:-1}
  printf '\e[%dA' "$num"
}

# shellcheck disable=SC2120
next_line() {
  local num=${1:-1}
  printf '\e[%dB' "$num"
}

delete_to_eol() {
  printf '\e[0K'
}

TUI_TAB=$(printf '\t')
TUI_NL=$(printf '\n')
TUI_ESC=$(printf '\e')

read_key() {
  local c1
  IFS= read -r -s -n 1 c1

  if [[ $c1 != "$TUI_ESC" ]]; then
    case $c1 in
      $TUI_TAB)
        echo "_tab"
        ;;
      $TUI_NL)
        echo "_nl"
        ;;
      $'\177') # https://unix.stackexchange.com/a/244617
        echo "_bs"
        ;;
      "")
        echo "_?"
        ;;
      *)
        echo "$c1"
        ;;
    esac
  else
    local cc
    local cc2
    read -r -s -n 2 cc
    read -s -r -n 1 -t 0.001 cc2
    if [[ -n $cc2 ]]; then
      cc="${cc}${cc2}"
    fi
    case $cc in
      '[A')
        echo "_up"
        ;;
      '[B')
        echo "_down"
        ;;
      '[C')
        echo "_right"
        ;;
      '[D')
        echo "_left"
        ;;
      '[H')
        echo "_home"
        ;;
      '[F')
        echo "_end"
        ;;
      '[Z')
        echo "_shift_tab"
        ;;
      '[5~')
        echo "_pgup"
        ;;
      '[6~')
        echo "_pgdn"
        ;;
      '[2~')
        echo "_ins"
        ;;
      '[3~')
        echo "_del"
        ;;
      *)
        echo "_?"
        ;;
    esac
  fi
}

TUI_LINES=

abom_init() {
  if [[ -n $TUI_LINES ]]; then
    return 1
  fi
  local lines=${1:-$LINES}
  local init_content=$2

  get_term_size
  hide_cursor

  TUI_LINES=$lines
  for (( i = 0; i < TUI_LINES; i++ )); do
    echo
  done
  prev_line_start "$TUI_LINES"

  abom_render "$init_content"
  trap abom_close SIGINT SIGQUIT
  return 0
}

abom_clear() {
  if [[ -z $TUI_LINES ]]; then
    return
  fi

  for (( i = 0; i < TUI_LINES; i++ )); do
    delete_to_eol
    next_line_start
  done

  prev_line_start "$TUI_LINES"
}

abom_render() {
  if [[ -z $TUI_LINES ]]; then
    return 1
  fi
  local content=$1

  abom_clear

  local root_pos
  root_pos=$(get_cursor_pos)
  local root_line
  root_line=$(get_line_from_pos "$root_pos")

  printf "%s" "$content"

  local curr_pos=
  curr_pos=$(get_cursor_pos)
  local diff_lines
  diff_lines=$(( $(get_line_from_pos "${curr_pos}") - root_line ))
  for (( i = 0; i < TUI_LINES - diff_lines; i++ )); do
    delete_to_eol
    next_line_start
  done

  prev_line_start "$s"
  return 0
}

abom_close() {
  if [[ -n $TUI_LINES ]]; then
    #abom_clear

    printf '\e[%dB' "$TUI_LINES"
    show_cursor
    trap - SIGINT SIGQUIT
    TUI_LINES=
  fi
}
