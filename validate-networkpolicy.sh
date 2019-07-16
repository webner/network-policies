#!/bin/bash
 
set -eo pipefail
shopt -s nullglob

listProjects() { 
    set -- */
    printf "%s\n" "${@%/}"
}

IFS=$'\n'

for p in $(listProjects); do
    echo "project: $p"

    for np in $p/*.yaml $p/*.yml $p/*.json; do
        oc apply -n "$p" -f "$np" --dry-run --validate
    done
done

