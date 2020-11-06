#!/usr/bin/env bash

echo "Current directory: $PWD"
#set -e
echo "List submodules defined in .gitmodules: "
git config --file .gitmodules --get-regexp path | awk '{ print $2 }'|sort
echo "=== end list ==="
echo "Restoring git submodules"
git config -f .gitmodules --get-regexp '^submodule\..*\.path$' |
    while read path_key submodule_path
    do
	echo ">Processing path key: ${path_key}"
	echo " > Processing path: ${submodule_path}"
	rm -rf ${submodule_path}
	url_key=$(echo ${path_key} | sed 's/\.path/.url/')
	echo " > Processing url_key: ${url_key}"
	url=$(git config -f .gitmodules --get "$url_key")
	echo " > Processing: ${url}"
	if [ $(git ls-files --cached "$submodule_path") ]; then
	    git rm --cached ${submodule_path}
    fi
	git submodule add -f ${url} ${submodule_path}
    set -e
    # WARNING: include end line
    # spaces are required before and after, to avoid matching partial path on local machine, but no on concourse containers !
	commit_ref=$(cat submodules.status|grep -e " ${submodule_path}$"|cut -b 2-|cut -d' ' -f1)
	echo " > Commit ref: $commit_ref"
	if [ -z "$commit_ref" ]; then
	    echo "ERROR: empty commit id, cannot restore git submodule $submodule_path" | tee -a submodule-restore-errors.log
	    continue
	fi
	if [ -d ${submodule_path} ]; then
        cd ${submodule_path}
	    echo " > Resetting to commit : [$commit_ref @ ${url}](${url}/commit/${commit_ref}) "
        git reset --hard ${commit_ref}
        cd -
	else
	    echo " > WARN - skipping, no submodule found at $submodule_path"
	fi
	set +e
	echo "________________"
    done
git submodule status > submodules.status.restored
