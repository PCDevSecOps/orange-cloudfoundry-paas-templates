cd ..
for u in $(ls ../../../shared-operators/cfcr-complementary-addon-products/*.yml  | sed -r 's/^.+\///'); do ln -s  ../../../shared-operators/cfcr-complementary-addon-products/$u $u ; done;