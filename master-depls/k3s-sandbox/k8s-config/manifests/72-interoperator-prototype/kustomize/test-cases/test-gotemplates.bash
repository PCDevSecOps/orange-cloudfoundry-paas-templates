#! /bin/bash

#--- Script parameters
SET_EXPECTED_OUTPUT_FLAG=false
VERBOSE_FLAG=false

#--- Check prerequisites
usage() {
  printf "\n%bUSAGE:" "${RED}"
  printf "\n  $(basename -- $0) [OPTIONS]\n\nOPTIONS:"
  printf "\n  %-40s %s" "--set-expected-output, -s" "Override the current expected output. Use git diff then to diff and commit"
  printf "\n  %-40s %s" "--verbose, -v" "Verbose mode"
  printf "%b\n\n"  "${STD}"
  exit 1
}

while [ "$#" -gt 0 ] ; do
  case "$1" in
    "-s"|"--set-expected-output") SET_EXPECTED_OUTPUT_FLAG=true ; shift ;;
    "-v"|"--verbose") VERBOSE_FLAG=true; shift ;;
    *) usage ;;
  esac
done

if [ $VERBOSE_FLAG = "true" ]; then
  set -x
fi
set -e
TEST_CASES=$(find . -mindepth 1 -type d )

# $1: path to json patch file
# write to
function extract_template_from_json_patch_file {
  rm -f template.yaml
  echo "{{- /* this is a read-only extract for rendering. To make permanent changes, edit $1 and commit/push" > template.yaml */ -}}
  bosh int $1  --path '/0/value/content' >> template.yaml
  chmod -w template.yaml # prevent accidental direct edition of the template instead of the json patch file
  ln -sf template.yaml template.yaml.tpl # symink with .tpl extension eases reading the template in the IDE with gotemplate rendering
}

for t in ${TEST_CASES}; do
  printf "testing ${t} ... "
  pushd $t > /dev/null
  extract_template_from_json_patch_file $(cat template-patch-file-symlink.yaml)
  /home/guillaume/public-code/gotemplate-test/gotemplate > output.yaml
  # Check parses as valid yaml
  if [ $SET_EXPECTED_OUTPUT_FLAG = "true" ] ; then
    echo "overriding expected-output.yaml"
    cp -f output.yaml expected-output.yaml
  else
    diff output.yaml expected-output.yaml
    bosh int output.yaml > /dev/null
    printf "OK\n"
  fi
  popd > /dev/null
done;

if [ $SET_EXPECTED_OUTPUT_FLAG = "true" ] ; then
  echo
  echo "Git status of overriden expected-output.yaml:"
  git status .
fi