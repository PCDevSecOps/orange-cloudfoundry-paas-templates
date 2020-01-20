cd ..
for u in $(ls ../../../shared-operators/cfcr-persistent-worker/*.yml  | sed -r 's/^.+\///'); do ln -s  ../../../shared-operators/cfcr-persistent-worker/$u $u ; done;