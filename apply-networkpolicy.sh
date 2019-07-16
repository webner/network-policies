#!/bin/bash
 
set -eo pipefail
shopt -s nullglob

ANNOTATION="catalysts.cc/synced-with-git=true"

listProjects() { 
    set -- */
    printf "%s\n" "${@%/}"
}

listCurrentNetworkPolicies() {
    oc -n "$1" get networkpolicy.networking.k8s.io -o name -l "$ANNOTATION" | sort
}

listDesiredNetworkPolicies() {
    if [[ "$(echo $1/*.yaml $1/*.yml $1/*.json)" ]]; then
        oc -n "$1" get -o name -f "$1" | sort
    fi
}

IFS=$'\n'

for p in $(listProjects); do
    echo "project: $p"

    for np in $p/*.yaml $p/*.yml $p/*.json; do
        oc -n "$p" label -f "$np" --local --dry-run -o yaml "$ANNOTATION" | oc -n "$p" apply -f -
    done

    np_to_delete=$(comm -23 <(listCurrentNetworkPolicies "$p") <(listDesiredNetworkPolicies "$p"))

    if [[ ! "$np_to_delete" == "" ]]; then
        for np in $np_to_delete; do
            oc -n "$p" delete "$np"
        done
    fi
    echo ""

done

