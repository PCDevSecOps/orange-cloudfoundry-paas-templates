#!/usr/bin/env bash
usage() {
    echo "$0"
    echo "  generates a tarball without vcs and vcs-ignores"
    exit 1
}

if [ $# -ne 0 ]
then
    usage
fi

tar czvf ../../paas-templates-sanitized.tgz --exclude-vcs --exclude-vcs-ignores --exclude=*.iml ../*
