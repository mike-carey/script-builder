#!/usr/bin/env bash 
function builder () 
{ 
    local _dist="${BUILDER_DIST:-dist}";
    local _util="${BUILDER_UTIL:-util}";
    local _lib="${BUILDER_LIB:-lib}";
    local _ext="${BUILDER_EXT:-.sh}";
    local _single_file=;
    while :; do
        case "$1" in 
            --dist)
                _dist="$2";
                shift;
                shift
            ;;
            --util)
                _util="$2";
                shift;
                shift
            ;;
            --lib)
                _lib="$2";
                shift;
                shift
            ;;
            --ext)
                _ext="$2";
                shift;
                shift
            ;;
            --single-file)
                _single_file="$2";
                shift;
                shift
            ;;
            --)
                shift;
                break
            ;;
            *)
                break
            ;;
        esac;
    done;
    if [[ "$@" = \- ]]; then
        if [[ -z "$_single_file" ]]; then
            _single_file='-';
        fi;
        shift;
    fi;
    local _args="$@";
    if [ "$_single_file" = \- ]; then
        local _r=$( cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1 );
        _single_file="$_dist/$_r$_ext";
    fi;
    local -a _files=($_args);
    local -a _utils=($( builder.find "$_util" "*$_ext" ));
    if [ ${#_files[@]} -eq 0 ]; then
        if [ ! -d $_lib ]; then
            { 
                echo "When no files are provided, the lib directory is required";
                echo "Please set the lib directory via \`--lib\` option or the \`BUILDER_LIB\` variable"
            } 1>&2;
            return 4;
        fi;
        _files=($( builder.find "$_lib" "*$_ext" ));
    fi;
    mkdir -p "$_dist";
    if [ -n "$_single_file" ]; then
        concat "$_single_file" ${_utils[@]} ${_files[@]};
        chmod +x "$_single_file";
        export BUILDER_DIST_FILE="$_single_file";
        echo "$BUILDER_DIST_FILE";
    else
        mkdir -p "$_dist";
        declare -a BUILDER_DIST_FILES=();
        for _file in ${_files[@]};
        do
            concat "$_dist"/"$_file" ${_utils[@]} "$_file";
            chmod +x "$_dist"/"$_file";
            BUILDER_DIST_FILES+=("$_file");
        done;
        export BUILDER_DIST_FILES;
        echo "${BUILDER_DIST_FILES[@]}";
    fi;
    return 0
};
function builder.find () 
{ 
    local _dir="$1";
    local _name="$2";
    if [ -z "$_dir" -o -z "$_name" ]; then
        echo "Usage builder.find DIR NAME" 1>&2;
        return 5;
    fi;
    declare -a _value=();
    if [ -d "$_dir" ]; then
        for d in $( find "$_dir" -name "$_name" );
        do
            _value+=("$d");
        done;
    fi;
    echo "${_value[@]}";
    return 0
};
function concat () 
{ 
    function concat.usage () 
    { 
        echo "Usage: concat [--comment] OUTPUT INPUT...";
        echo "  --comment   Adds comments";
        echo "  OUPUT       The output file";
        echo "  INPUT       The input files"
    };
    local _comment=1;
    while :; do
        case "$1" in 
            --comment)
                _comment=0;
                shift
            ;;
            --help)
                concat.usage;
                return 0
            ;;
            --)
                shift;
                break
            ;;
            *)
                break
            ;;
        esac;
    done;
    local outputPath="$1";
    local -a inputFiles=("${@:2}");
    local blob;
    local file;
    if [ -z "$outputPath" -o ${#inputFiles[@]} -lt 1 ]; then
        concat.usage 1>&2;
        return 2;
    fi;
    echo "Creating $outputPath from ${inputFiles[@]}";
    mkdir -p "$( dirname "$outputPath" )";
    for file in "${inputFiles[@]}";
    do
        if [ ! -s "$file" ]; then
            echo "Skipping '$file' because it is empty";
            continue;
        else
            echo "Adding '$file' to blob";
        fi;
        blob+='
';
        if [ $_comment -eq 0 ]; then
            blob+="# START -- $file";
        fi;
        blob+=$(<"$file");
        if [ $_comment -eq 0 ]; then
            blob+="# FINISH -- $file";
        fi;
    done;
    if [ -z "${blob}" ]; then
        echo "No contents could be found.  All files are empty." 1>&2;
        return 5;
    fi;
    eval "main() { ${blob} " '
' " }";
    if [[ ! -z "${replaceAliases+x}" ]]; then
        main;
    fi;
    local body=$(declare -f main);
    body="${body#*{}";
    body="${body%\}}";
    printf %s "#!/usr/bin/env bash" > "$outputPath";
    while IFS= read -r line; do
        [[ "$line" == '    '* ]] && line="${line:4}";
        [[ "$line" == 'namespace '* ]] && continue;
        printf %s "$line" >> "$outputPath";
        printf "\n" >> "$outputPath";
    done <<< "$body";
    return 0
};
if [[ ${BASH_SOURCE[0]} != $0 ]]; then
    export -f concat;
else
    {{FUNCTION}} "${@}";
    exit $?;
fi;
if [[ ${BASH_SOURCE[0]} != $0 ]]; then
    export -f builder;
else
    {{FUNCTION}} "${@}";
    exit $?;
fi

