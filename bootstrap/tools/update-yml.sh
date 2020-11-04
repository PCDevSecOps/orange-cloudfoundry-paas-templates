#!/bin/bash
#=====================================================================================
# Update value in yaml manifest (only "key: value" format, no multi-line or lists)
# $1 : yaml file (e.g: secrets.yml)
# $2 : Path to key (e.g: secrets.cloudfoundry.system_domain)
# $3 : Value to update (e.g: 192.xxx.xxx.xxx)
#=====================================================================================

YAML_FILE="$1"
KEY_PATH="$2"
VALUE="$3"
NEW_FILE="$1.tmp"

#--- Colors and styles
export RED='\033[1;31m'
export YELLOW='\033[1;33m'
export GREEN='\033[1;32m'
export STD='\033[0m'
export BOLD='\033[1m'
export REVERSE='\033[7m'

update_yaml() {
  awk -v new_file="$2" -v refpath="$3" -v value="$4" 'BEGIN {nb = split(refpath, path, ".") ; level = 1 ; flag = 0 ; string = ""}
  {
    line = $0
    currentLine = $0 ; gsub("^ *", "", currentLine)
    key = path[level]":"
    if (index(currentLine, key) == 1) {
      if(level == nb) {
        level = level + 1 ; path[level] = "@" ; flag = 1
        sub("^ *", "", value) ; sub(" *$", "", value)
        gsub(":.*", ": "value, line)
      }
      else {level = level + 1}
      string = string "\n" line
    }
    printf("%s\n", line) >> new_file
  }
  END {if(flag == 0){exit 1} else {printf("%s", string)}}' $1
  if [ $? != 0 ] ; then
    printf "\n%bERROR: Value [%s] incorrect for update.%b\n\n" "${RED}${BOLD}" "$4" "${STD}"
    rm -f ${NEW_FILE} > /dev/null 2>&1
    exit 1
  fi
}

if [ $# != 3 ] ; then
  printf "\n%bUsage : %s <yaml file name> <key path (e.g: secrets.cloudfoundry.system_domain)> <value to update (e.g: '8080')>%b\n\n" "${YELLOW}${BOLD}" "$0" "${STD}"
  exit 1
fi
if [ ! -s ${YAML_FILE} ] ; then
  printf "\n%bERROR : File \"%s\" unknown.%b\n\n" "${RED}${BOLD}" "${YAML_FILE}" "${STD}"
  exit 1
fi

#--- Update manifest yaml with "key: value"
> ${NEW_FILE}
update_yaml "${YAML_FILE}" "${NEW_FILE}" "${KEY_PATH}" "${VALUE}"
if [ $? != 0 ] ; then
  printf "\n%bERROR: Unknown key [%s] in file \"%s\".%b\n\n" "${RED}${BOLD}" "${KEY_PATH}" "${YAML_FILE}" "${STD}"
else
  cp ${NEW_FILE} ${YAML_FILE}
fi
rm -f ${NEW_FILE} > /dev/null 2>&1
printf "\n"