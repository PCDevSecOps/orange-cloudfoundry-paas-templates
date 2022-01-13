#!/bin/sh

#01-cf-mysql-extended
cd ../../../coab-depls/01-cf-mysql-extended/template
ln -sf ../../../shared-operators/coab/monitoring-operators/80-prepare-monitoring-as-addon-on-broker-operators.yml 80-prepare-monitoring-as-addon-operators.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/81-add-monitoring-common-addon-operators.yml 81-add-monitoring-common-addon-operators.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/81-add-monitoring-common-addon-vars.yml 81-add-monitoring-common-addon-vars.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/81-add-monitoring-common-included-operators.yml 81-add-monitoring-common-included-operators.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/81-add-monitoring-common-included-vars.yml 81-add-monitoring-common-included-vars.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/82-add-monitoring-custom-addon-operators.yml 82-add-monitoring-custom-addon-operators.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/82-add-monitoring-custom-addon-cf-mysql-vars.yml 82-add-monitoring-custom-addon-vars.yml
cd -


#02-redis-extended
cd ../../../coab-depls/02-redis-extended/template
ln -sf ../../../shared-operators/coab/monitoring-operators/80-prepare-monitoring-as-addon-on-broker-operators.yml 80-prepare-monitoring-as-addon-operators.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/81-add-monitoring-common-addon-operators.yml 81-add-monitoring-common-addon-operators.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/81-add-monitoring-common-addon-vars.yml 81-add-monitoring-common-addon-vars.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/81-add-monitoring-common-included-operators.yml 81-add-monitoring-common-included-operators.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/81-add-monitoring-common-included-vars.yml 81-add-monitoring-common-included-vars.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/82-add-monitoring-custom-addon-operators.yml 82-add-monitoring-custom-addon-operators.yml

cd -

#cf-mysql
cd ../../../coab-depls/cf-mysql/template
ln -sf ../../../shared-operators/coab/monitoring-operators/80-prepare-monitoring-as-addon-on-shield-operators.yml 80-prepare-monitoring-as-addon-operators.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/81-add-monitoring-common-addon-operators.yml 81-add-monitoring-common-addon-operators.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/81-add-monitoring-common-addon-vars.yml 81-add-monitoring-common-addon-vars.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/81-add-monitoring-common-included-operators.yml 81-add-monitoring-common-included-operators.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/81-add-monitoring-common-included-vars.yml 81-add-monitoring-common-included-vars.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/82-add-monitoring-custom-addon-operators.yml 82-add-monitoring-custom-addon-operators.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/82-add-monitoring-custom-addon-cf-mysql-vars.yml 82-add-monitoring-custom-addon-vars.yml
cd -

#cf-rabbit
cd -
cd ../../../coab-depls/cf-rabbit/template
ln -sf ../../../shared-operators/coab/monitoring-operators/80-prepare-monitoring-as-addon-on-shield-operators.yml 80-prepare-monitoring-as-addon-operators.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/81-add-monitoring-common-addon-operators.yml 81-add-monitoring-common-addon-operators.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/81-add-monitoring-common-addon-vars.yml 81-add-monitoring-common-addon-vars.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/81-add-monitoring-common-included-operators.yml 81-add-monitoring-common-included-operators.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/81-add-monitoring-common-included-vars.yml 81-add-monitoring-common-included-vars.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/82-add-monitoring-custom-addon-operators.yml 82-add-monitoring-custom-addon-operators.yml
cd -

#mongodb dedicated
cd ../../../coab-depls/mongodb/template
ln -sf ../../../shared-operators/coab/monitoring-operators/80-prepare-monitoring-as-addon-on-shield-operators.yml 80-prepare-monitoring-as-addon-operators.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/81-add-monitoring-common-addon-operators.yml 81-add-monitoring-common-addon-operators.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/81-add-monitoring-common-addon-vars.yml 81-add-monitoring-common-addon-vars.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/81-add-monitoring-common-included-operators.yml 81-add-monitoring-common-included-operators.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/81-add-monitoring-common-included-vars.yml 81-add-monitoring-common-included-vars.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/82-add-monitoring-custom-addon-operators.yml 82-add-monitoring-custom-addon-operators.yml
cd -

#mongodb shared
cd ../../../ops-depls/mongodb/template
ln -sf ../../../shared-operators/coab/monitoring-operators/81-add-monitoring-common-addon-operators.yml 81-add-monitoring-common-addon-operators.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/81-add-monitoring-common-addon-vars.yml 81-add-monitoring-common-addon-vars.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/81-add-monitoring-common-included-operators.yml 81-add-monitoring-common-included-operators.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/81-add-monitoring-common-included-vars.yml 81-add-monitoring-common-included-vars.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/82-add-monitoring-custom-addon-operators.yml 82-add-monitoring-custom-addon-operators.yml
cd -

#redis
cd ../../../coab-depls/redis/template
ln -sf ../../../shared-operators/coab/monitoring-operators/80-prepare-monitoring-as-addon-on-broker-operators.yml 80-prepare-monitoring-as-addon-operators.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/81-add-monitoring-common-addon-operators.yml 81-add-monitoring-common-addon-operators.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/81-add-monitoring-common-addon-vars.yml 81-add-monitoring-common-addon-vars.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/81-add-monitoring-common-included-operators.yml 81-add-monitoring-common-included-operators.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/81-add-monitoring-common-included-vars.yml 81-add-monitoring-common-included-vars.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/82-add-monitoring-custom-addon-operators.yml 82-add-monitoring-custom-addon-operators_plan-coab-redis-small.yml
ln -sf ../../../shared-operators/coab/monitoring-operators/82-add-monitoring-custom-addon-operators.yml 82-add-monitoring-custom-addon-operators_plan-coab-redis-sentinelsmall.yml
cd -