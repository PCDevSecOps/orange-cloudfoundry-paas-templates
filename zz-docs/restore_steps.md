# Why

This document aime to provide manual steps to restore services such as mysql, postgres ...

We are using the shield-boshrelease to perform backup and restore operations under paas-template. To be able to restore some services, we have to perform some
manuals steps.

# Postgres

Steps :
* bosh ssh to the postgres vm
* sudo su
* monit stop postgres
* rm -rf /var/vcap/store/postgres
* run  pre-start or postgres_start.sh (for postgres version lower than v22) script /var/vcap/jobs/postgres/bin/
* monit start postgres
* restore the postgres backup via shield
* monit restart postgres

# Mysql
Steps:

If you are using shield v6 :

https://github.com/orange-cloudfoundry/cf-oss-service-providers-best-practices/blob/master/backup-restore-instructions-with-shield.md

If you are using shield v7/v8 :

https://github.com/orange-cloudfoundry/cf-oss-service-providers-best-practices/blob/master/backup-restore-PITR-instructions-with-shield-v7-v8-eng.md


# Openldap

Steps:
* bosh ssh to the openldap vm
* sudo su
* monit stop ldap-server
* restore the openldap backup via shield
* monit start ldap-server



# RabbitMQ

You have to reduce the rabbitMq cluster to one node.

Steps:
* bosh ssh to the rabbitMQ broker VM
* sudo su
* monit stop rabbitmq-broker
* bosh ssh to the rabbitmq server VM
* sudo su
* monit stop rabbitmq-server
* rm -rf /var/vcap/store/rabbitmq
* restore the rabbitMq backup via shield
* bosh ssh to the rabbitMQ broker
* sudo su
* monit  start rabbitmq-broker
* bosh ssh to the rabbitMQ server
* sudo su
* monit start rabbitmq-server



# Blobstore


# BOSH deployments

All bosh deployment under Paas-template  are using a postgres databases so to be able to restore a bosh deployment you need to
follow the same steps as the Postgres section


#

