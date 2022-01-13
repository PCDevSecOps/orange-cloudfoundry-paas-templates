#!/bin/bash
#set -e
version=$1
if [ -z "$version" ];then
  echo "ERROR: missing version (Expected format: <x.y.z>"
  exit 1
fi

version_underscore=${version//./_}
release_notes_file="../zz-docs/release-notes/V${version_underscore}.md"
release_notes_file_reference="${release_notes_file}.reference"
release_notes_file_tmp="${release_notes_file}.tmp"
manual_step_overview_file="../zz-docs/release-notes/V${version_underscore}-manual-steps-overview.md"

if ! [ -e "$release_notes_file" ];then
  echo "ERROR - Release notes file does not exist: $release_notes_file"
  exit 1
fi

echo "################ start preprocessing ##################"

cp -p "$release_notes_file" "$release_notes_file_reference"
EXPECTED_MANUAL_OPS_COUNT=$(grep "^### Manual platform ops" "$release_notes_file" -c)

echo 'Removing ```[a-z].* to ease manual steps extraction'
mv "$release_notes_file" "${release_notes_file_tmp}"
sed -e 's/```[a-z].*/```/g' "${release_notes_file_tmp}" > "${release_notes_file}"
rm -f "${release_notes_file_tmp}"

echo 'Removing "* [ ] Openstack Iaas Type" to ease manual steps extraction'
mv "$release_notes_file" "${release_notes_file_tmp}"
sed -e 's/\* \[ ] Openstack Iaas Type//g' "${release_notes_file_tmp}" > "${release_notes_file}"
rm -f "${release_notes_file_tmp}"

echo 'Removing "* [ ] vSphere Iaas Type" to ease manual steps extraction'
mv "$release_notes_file" "${release_notes_file_tmp}"
sed -e 's/\* \[ ] vSphere Iaas Type//g' "${release_notes_file_tmp}" > "${release_notes_file}"
rm -f "${release_notes_file_tmp}"

echo 'Removing TaskList to ease manual steps extraction'
mv "$release_notes_file" "${release_notes_file_tmp}"
sed -e 's/\[[x|X| ]\]//g' "${release_notes_file_tmp}" > "${release_notes_file}"
rm -f "${release_notes_file_tmp}"

echo "################ end preprocessing ##################"

echo 'Starting manual steps extraction'
ruby ./manual_step_extractor.rb -v "$version" --no-html

mv "$release_notes_file_reference" "$release_notes_file"
if ! [ -e "$manual_step_overview_file" ];then
  echo "ERROR - File does not exist: $manual_step_overview_file"
  exit 1
fi

MANUAL_OPS_COUNT=$(grep "^## feature" "${manual_step_overview_file}"|sort|uniq|wc -l)
echo "Checking manual steps overview consistency"
if ! [ "$MANUAL_OPS_COUNT" = "$EXPECTED_MANUAL_OPS_COUNT" ];then
  echo "ERROR - inconsistency detected after $manual_step_overview_file generation"
  EXPECTED_MANUAL_OPS=$(grep -E "## feature-.*|### Manual platform ops" "$release_notes_file"|grep "### Manual platform ops" -B1|grep feature|sort)
  echo -e "\t Found $MANUAL_OPS_COUNT steps, expected manual ops count: $EXPECTED_MANUAL_OPS_COUNT"
  MANUAL_OPS=$(grep "^## feature" "${manual_step_overview_file}"|sort)
  echo -e "\t Expected feature with manual operations:\n $EXPECTED_MANUAL_OPS\n"
  echo -e "\t Found feature list:\n  $(echo "$MANUAL_OPS"|uniq -c)\n"
  DIFF_RESULT=$(diff <( printf '%s\n' "$EXPECTED_MANUAL_OPS" ) <( printf '%s\n' "$MANUAL_OPS" ))
  echo "========="
  echo -e "Diff (expected / found):\n $DIFF_RESULT"
  exit 1
fi

block_count="$(cat "$release_notes_file"|grep -B 1 '```'|grep -v '\-\-'|awk '{print;getline;}'|awk '{print;getline;}'|uniq -c |wc -l)"
if [ "$block_count" != "1" ]; then
  echo 'Code block ("```") definition may lead to doc generation inconsistencies. Please ensure each code block is preceded by an empty blank line'
  echo "Listing release notes matching lines:"
  # we skip first forth line as it is part of our template
  cat "$release_notes_file"|grep -B 1 '```' -n|grep -v '\-\-'|awk '{select=x%4;if (NR > 4 && (select < 2)) {print}x++}'|awk '{if (NR % 2 == 1){print "--"}print}'
fi

echo "Done"