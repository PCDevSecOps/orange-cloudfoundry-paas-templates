#!/bin/bash
>list.out
for directory in $(find . -type d -name 'cf_*'); do
 cd ${directory} 
 d=$(ls -got --time-style="+%Y-%m-%d"  | grep ^- | head -1 | awk '{print $4}')
 line=${directory}-${d} 
 cd ..
 echo ${line} >> list.out
done

