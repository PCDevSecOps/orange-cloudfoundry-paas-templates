cd ..
for u in $(find . -type l); do rm $u;done
for u in $(ls ../../../shared-operators/cfcr-common-serv/*.yml  | sed -r 's/^.+\///'); do ln -s  ../../../shared-operators/cfcr-common-serv/$u $u ; done;
for u in $(ls ../../../shared-operators/k8s-prometheus/*.yml  | sed -r 's/^.+\///'); do ln -s  ../../../shared-operators/k8s-prometheus/$u $u ; done;
