#!/usr/bin/env bash

usage() {
    echo "$0"
    echo "  propose a list of non sanitized files to delete"
    exit 1
}
#--- Colors and styles
export GREEN='\033[1;32m'
export YELLOW='\033[1;33m'
export ORANGE='\033[0;33m'
export RED='\033[1;31m'
export STD='\033[0m'
export BOLD='\033[1m'
export REVERSE='\033[7m'

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

# shellcheck disable=SC2086
FILE_LIST=$(git-secrets --scan -r ${SCAN_FILE_LIST} 2>&1|grep :|grep /|cut -d':' -f1|sort|uniq)
echo "***********************************"
printf "%bPlease adjust paas-templates/bin/sanitized.sh, with command below:%b\n" "${YELLOW}${BOLD}" "${STD}"
printf "%bAlternatively, remove the leak, or mark each leak as validated (using '# credential_leak_validated' or '#credential_leak_validated')%b\n" "${YELLOW}${BOLD}" "${STD}"
printf "%bRules are defined in <paas-templates-dir>/.git-secret-config.sh%b\n" "${YELLOW}" "${STD}"
for i in ${FILE_LIST};do
  subpath=$(echo ${i}|cut -c 3-)
  printf "%b\${RM_CMD} \${ROOT_DIR}/${subpath}%b\n" "${RED}${BOLD}" "${STD}"
done
echo "***********************************"

cd -
