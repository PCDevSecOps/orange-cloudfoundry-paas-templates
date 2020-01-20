#!/usr/bin/env bash

echo "Current directory: $PWD"
#set -e
echo "List submodules defined in .gitmodules: "
git config --file .gitmodules --get-regexp path | awk '{ print $2 }'|sort
echo "=== end list ==="

echo "Restoring git submodules"
git config -f .gitmodules --get-regexp '^submodule\..*\.path$' |
    while read path_key path
    do
	echo ">Processing path key: ${path_key}"
	echo " > Processing path: ${path}"
	rm -rf $path
	url_key=$(echo $path_key | sed 's/\.path/.url/')
	echo " > Processing url_key: ${url_key}"
	url=$(git config -f .gitmodules --get "$url_key")
	echo " > Processing: ${url}"
	git submodule add -f $url $path
    set -e
    # WARNING: include end line
    # spaces are required before and after, to avoid matching partial path on local machine, but no on coucourse containers !
	commit_ref=$(cat submodules.status|grep -e " ${path}$"|cut -b 2-|cut -d' ' -f1)
	echo " > Commit ref: $commit_ref"
	if [ -z "$commit_ref" ]; then
	    echo "ERROR: empty commit id, cannot restore git submodule"
	    exit 1
	fi
	if [ -d ${path} ]; then
        cd $path
	    echo " > Resetting to commit : [$commit_ref @ ${url}](${url}/commit/${commit_ref}) "
        git reset --hard $commit_ref
        cd -
#        git add $path
	else
	    echo " > WARN - skipping, no submodule found at $path"
	fi
	set +e
	echo "________________"
    done
git submodule status > submodules.status.restored
