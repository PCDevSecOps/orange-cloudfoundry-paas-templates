cd ..
for u in $(ls ../../../shared-operators/cfcr-core-addon-products/*.yml  | sed -r 's/^.+\///'); do ln -s  ../../../shared-operators/cfcr-core-addon-products/$u $u ; done;