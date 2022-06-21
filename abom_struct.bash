# A struct, which is a set of key/value pairs, is represented as a string.
# Each key/value pair is separated from others with an ASCII RS (record
# separator) character, hex 1e. The key and value in each pair is separated by
# an ASCII US (unit separator) character, hex 1f.
#
# Empty keys cause undefined behavior. Empty values are not supported; setting
# an empty value deletes its key.

make_struct() {
  local s=""
  local argct=$#
  for (( i = 0; i < argct; i += 2 )); do
    local key=$1
    local value=$2
    if [[ -z $value ]]; then
      continue
    fi
    if [[ -n $s ]]; then
      s=$(printf '%s\x1e' "${s}")
    fi
    s=$(printf '%s%s\x1f%s' "$s" "$key" "$value")
    shift 2
  done

  echo "$s"
}

struct_get() {
  local s=$1
  local k=$2

  while [[ ! $s =~ ^$k$'\x1f' ]]; do
    local nexts=${s#*$'\x1e'}
    if [[ $nexts == "$s" ]]; then
      s=""
      break
    fi
    s=$nexts
  done
  if [[ -z $s ]]; then
    echo
  else
    local pair=${s%%$'\x1e'*}
    echo "${pair#*$'\x1f'}"
  fi
}

struct_set() {
  local s=$1
  local k=$2
  local v=$3

  local news=()
  local found=
  while [[ -n $s ]]; do
    local thiskv=${s%%$'\x1e'*}
    local thisk=${thiskv%%$'\x1f'*}
    if [[ $thisk == "$k" ]]; then
      if [[ -n $v ]]; then
        news+=( "$thisk" "$v" )
      fi
      found=1
    else
      local thisv=${thiskv#*$'\x1f'}
      news+=( "$thisk" "$thisv" )
    fi

    if [[ $thiskv == "$s" ]]; then
      break
    fi
    s=${s#*$'\x1e'}
  done

  if [[ -z $found ]]; then
    news+=( "$k" "$v" )
  fi

  make_struct "${news[@]}"
}

struct_del() {
  local s=$1
  local k=$2

  struct_set "$s" "$k" ""
}
