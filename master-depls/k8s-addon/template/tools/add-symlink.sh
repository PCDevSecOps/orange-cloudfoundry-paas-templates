cd ..
for u in $(find . -type l); do rm $u;done
for u in $(ls ../../../shared-operators/cfcr-common-master/*.yml  | sed -r 's/^.+\///'); do ln -s  ../../../shared-operators/cfcr-common-master/$u $u ; done;
for u in $(ls ../../../shared-operators/k8s-addon/*.yml  | sed -r 's/^.+\///'); do ln -s  ../../../shared-operators/k8s-addon/$u $u ; done;
