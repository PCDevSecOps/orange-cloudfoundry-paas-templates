#!/bin/bash

deployments_y=$(bosh deployments --column=Name | grep -vE "^Name$|^Succeeded$|^[0-9]* deployments$" | grep "^y_" > deployments_y.lst)
deployments_m=$(bosh deployments --column=Name | grep -vE "^Name$|^Succeeded$|^[0-9]* deployments$" | grep "^m_" > deployments_m.lst)
deployments_r=$(bosh deployments --column=Name | grep -vE "^Name$|^Succeeded$|^[0-9]* deployments$" | grep "^r_" > deployments_r.lst)
deployments_t=$(bosh deployments --column=Name | grep -vE "^Name$|^Succeeded$|^[0-9]* deployments$" | grep "^t_" > deployments_t.lst)

#change shield password for cf-mysql model
echo "begin processing cf-mysql"
bosh -d cf-mysql ssh shield -c "/var/vcap/jobs/errand-scripting/bin/run"
bosh -d cf-mysql run-errand --instance=shield import
echo "end processing cf-mysql"

#change shield password for mongodb model
echo "begin processing mongodb"
bosh -d mongodb ssh shield -c "/var/vcap/jobs/errand-scripting/bin/run"
bosh -d mongodb run-errand --instance=shield import
echo "end processing mongodb"

#change shield password for cf-rabbit model
echo "begin processing cf-rabbit"
bosh -d cf-rabbit ssh shield -c "/var/vcap/jobs/errand-scripting/bin/run"
bosh -d cf-rabbit run-errand --instance=shield import
echo "end processing cf-rabbit"

#change shield password for 01-cf-mysql-extended model
echo "begin processing 01-cf-mysql-extended"
bosh -d 01-cf-mysql-extended ssh broker -c "/var/vcap/jobs/errand-scripting/bin/run"
bosh -d 01-cf-mysql-extended run-errand --instance=broker import
echo "end processing 01-cf-mysql-extended"

#change shield password for mysql deployments
for deployment in $(cat deployments_y.lst); do
    echo "begin processing ${deployment}"
    bosh -d ${deployment} ssh shield -c "/var/vcap/jobs/errand-scripting/bin/run"
    bosh -d ${deployment} run-errand --instance=shield import
    echo "end processing ${deployment}"
done

#change shield password for mongodb deployments
for deployment in $(cat deployments_m.lst); do
    echo "begin processing ${deployment}"
    bosh -d ${deployment} ssh shield -c "/var/vcap/jobs/errand-scripting/bin/run"
    bosh -d ${deployment} run-errand --instance=shield import
    echo "end processing ${deployment}"
done

#change shield password for cf-rabbit deployments
for deployment in $(cat deployments_r.lst); do
    echo "begin processing ${deployment}"
    bosh -d ${deployment} ssh shield -c "/var/vcap/jobs/errand-scripting/bin/run"
    bosh -d ${deployment} run-errand --instance=shield import
    echo "end processing ${deployment}"
done

#change shield password for mysql extended deployments
for deployment in $(cat deployments_t.lst); do
    echo "begin processing ${deployment}"
    bosh -d ${deployment} ssh broker -c "/var/vcap/jobs/errand-scripting/bin/run"
    bosh -d ${deployment} run-errand --instance=broker import
    echo "end processing ${deployment}"
done