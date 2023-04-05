#!/bin/sh

set -e

workDir=''

help() {
    echo 'Usage: cp-config.sh [SOURCE]'
    echo 'Copy config files'
    echo
    echo 'Example:'
    echo -e 'cp-config.sh /home/config/'
}

check() {
	if [ ! $# == 1 ]; then
		help
		exit 1
	fi
}

# Override config files
copy_config_files() {
    declare source="$1"

	if [ ! -d "$source" ]; then
		echo 'source is not found' >&2
		exit 1
	fi

    if [ "${workDir}" = "" ]; then
        workDir="${source}"
    fi

    for f in $source/*; do
        if [ -d $f ]; then
            copy_config_files $f
        else
            target=$(echo $f | sed "s:^${workDir}::")
            targetDir=$(dirname "$target")
            echo "'$f' -> '${target}'"
            # mkdir -p "$targetDir"
            # cp "$f" "$target"
        fi
    done
}

check $*
copy_config_files $*
