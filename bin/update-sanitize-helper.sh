#!/usr/bin/env bash

usage() {
    echo "$0"
    echo "  propose a list of non sanitized files to delete"
    exit 1
}

. ./load-git-secrets-env.sh

ROOT_DIR=".."
while getopts ":h" option; do
    case "${option}" in
        h)
            usage
            ;;
        \?)
            echo "Invalid option: $OPTARG" >&2
            usage
            ;;
        *)
            usage
            ;;
    esac
done

cd ..
SCAN_FILE_LIST=$(find . -maxdepth 1 -type d|grep -v .git|grep -v ./vendor|grep -v ./submodules|grep ./)

FILE_LIST=$(git-secrets --scan -r ${SCAN_FILE_LIST} 2>&1|grep :|grep /|cut -d':' -f1|sort|uniq)
echo "***********************************"
echo "Please adjust paas-templates/bin/sanitized.sh, with the following:"
for i in ${FILE_LIST};do
  subpath=$(echo ${i}|cut -c 3-)
  echo '${RM_CMD} ${ROOT_DIR}/'"${subpath}"
done
echo "***********************************"

cd -
