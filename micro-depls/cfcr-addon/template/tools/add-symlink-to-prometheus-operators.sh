cd ..
for u in $(ls ../../../shared-operators/cfcr-prometheus/*.yml  | sed -r 's/^.+\///'); do ln -s  ../../../shared-operators/cfcr-prometheus/$u $u ; done;