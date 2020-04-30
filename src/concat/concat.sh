#!/usr/bin/env bash

function concat () {
  function concat.usage() {
    echo "Usage: concat [--comment] OUTPUT INPUT..."
    echo "  --comment   Adds comments"
    echo "  OUPUT       The output file"
    echo "  INPUT       The input files"
  }

  local _comment=1
  while : ; do
    case "$1" in
      --comment )
        _comment=0
        shift
        ;;
      --help )
        concat.usage
        return 0
        ;;
      -- )
        shift
        break
        ;;
      * )
        break
        ;;
    esac
  done

  local outputPath="$1"
  local -a inputFiles=("${@:2}")

  local blob
  local file

  if [ -z "$outputPath" -o ${#inputFiles[@]} -lt 1 ]; then
      concat.usage 1>&2
      return 2
  fi

  echo "Creating $outputPath from ${inputFiles[@]}"
  mkdir -p "$( dirname "$outputPath" )"

  for file in "${inputFiles[@]}"; do
    if [ ! -s "$file" ]; then
      echo "Skipping '$file' because it is empty"
      continue
    else
      echo "Adding '$file' to blob";
    fi

    blob+=$'\n'
    if [ $_comment -eq 0 ]; then
      blob+="# START -- $file"
    fi

    blob+=$(<"$file")

    if [ $_comment -eq 0 ]; then
      blob+="# FINISH -- $file"
    fi

  done

  if [ -z "${blob}" ]; then
    echo "No contents could be found.  All files are empty." 1>&2
    return 5
  fi

  eval "main() { ${blob} " $'\n' " }";
  if [[ ! -z "${replaceAliases+x}" ]]; then
    main
  fi

  local body=$( declare -f main )
  body="${body#*{}"
  body="${body%\}}"
  printf %s "#!/usr/bin/env bash" > "$outputPath"
  while IFS= read -r line; do
    [[ "$line" == '    '* ]] && line="${line:4}"
    [[ "$line" == 'namespace '* ]] && continue
    printf %s "$line" >> "$outputPath"
    printf "\n" >> "$outputPath"
  done <<< "$body"

  return 0
}

if [[ ${BASH_SOURCE[0]} != $0 ]]; then
  export -f concat
else
  concat "${@}"
  exit $?
fi
