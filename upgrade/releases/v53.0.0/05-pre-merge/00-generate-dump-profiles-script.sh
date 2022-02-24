#!/usr/bin/env bash

CONFIG_DIR=$1


dump_profiles_script="dump-profiles.sh"

filepath="$CONFIG_DIR/coa/config/$dump_profiles_script"

cat <<EOF >"$filepath"
#!/bin/sh

local_dir=\$(dirname \$0)
profiles_file="\$local_dir/credentials-active-profiles.yml"
if [ -f "\$profiles_file" ];then
  echo "Active profiles:";grep -e "^profiles:" "\$profiles_file"|cut -c 11-|xargs -d , -n 1 echo -e "\t"|sort
else
  echo "No profile found: \$profiles_file does not exist"
fi
EOF

chmod a+x "$filepath"
echo "Dump profiles script created at $filepath"


