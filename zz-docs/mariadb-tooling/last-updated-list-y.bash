#!/bin/bash
deployments_y=$(bosh deployments --column=Name | grep -vE "^Name$|^Succeeded$|^[0-9]* deployments$" | grep "^y_" > deployments_y.lst)
for deployment in $(cat deployments_y.lst); do
    echo "begin processing ${deployment}"
    bosh -d ${deployment} scp last-updated.bash mysql/0:/tmp/.
    bosh -d ${deployment} ssh mysql/0 -c "sudo bash /tmp/last-updated.bash"
    bosh -d ${deployment} scp mysql/0:/tmp/last-updated.out .
    mv last-updated.out last-updated-${deployment}.out
    echo "end processing ${deployment}"
done