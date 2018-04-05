#!/usr/bin/env bash 
function bin-builder () 
{ 
    local _force=1;
    local _bin;
    local _lib;
    local _ext;
    while :; do
        case "$1" in 
            --extension)
                _ext="$2";
                shift;
                shift
            ;;
            -f | --force)
                _force=0;
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
    _bin=${1:-bin};
    _lib=${2:-lib};
    _ext=${3:-.sh};
    mkdir -p "$_bin";
    for i in $( cd "$_lib" && ls *${_ext} );
    do
        local _link="$_bin/${i/${_ext}/}";
        local _file="../$_lib/$i";
        if [ -e "$_link" ]; then
            if [ ! -h "$_link" -o "$( readlink -- "$_link" )" != "$_file" ]; then
                if [ $_force -ne 0 ]; then
                    echo "Cowardly refusing to overwrite '$_link'" 1>&2;
                    return 2;
                fi;
            fi;
        fi;
        echo "Linking '$_link' -> '$_file'";
        $( cd "$_bin" && ln -fs "$_file" "${_link/${_bin}\//}" );
    done
};
if [[ ${BASH_SOURCE[0]} != $0 ]]; then
    export -f bin-builder;
else
    {{FUNCTION}} "${@}";
    exit $?;
fi

