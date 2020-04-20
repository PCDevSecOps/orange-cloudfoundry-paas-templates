#!/bin/sh
# ========================
#    Aim of this script  :
# ========================
# create all the symlink in template directory
# from /shared-operators/cfcr/
# all this link represent common operators between
# all CFCR deployment micro/master/ops
# be careful:
# It doesn't add new link in git for you
# It doesn't remove deleted link for you

cd ..
for u in $(find . -type l); do rm $u;done
for u in $(ls ../../../shared-operators/cfcr/*.yml  | sed -r 's/^.+\///'); do ln -s  ../../../shared-operators/cfcr/$u $u ; done;
for u in $(ls ../../../shared-operators/cfcr-common-micro/*.yml  | sed -r 's/^.+\///'); do ln -s  ../../../shared-operators/cfcr-common-micro/$u $u ; done;
