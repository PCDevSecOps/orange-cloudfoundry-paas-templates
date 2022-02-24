## mariadb tooling readme

__shared services__
in order to list potential unused shared services : 
- connect to docker-boshcli
- connect to ops-depls/cloudfoundry-mysql with log-bosh
- transfer list.bash script to one of the mysql nodes (/var/vcap/store/mysql) with bosh scp command 
- execute list.bash script in order to generate a list.out file like below
```
./cf_c9ff48bc_98d0_4662_a103_2d096e51f6bb-2021-01-20
./cf_a31c709b_6385_4128_b2bf_3162ecc34652-2021-01-20
./cf_9451d5c9_e40e_4366_8035_a1f0c9ab1ed5-2021-01-20
./cf_910a16b3_54ed_4219_9d02_476e23883d40-2021-04-01
./cf_c20cd530_f4e0_415d_8042_a631ce409f31-2021-02-10
```
for each service (cf_xx) it gives the most recent data file
- with a grep command you can list services that have not been updated for a long time period

__dedicated services__
in order to list potential unused dedicated services : 
- connect to docker-boshcli
- connect to coab-depls
- execute last-updated-list-y.bash script in order to search for last update service date (meta information in the database). A file like below will be generated : 
- cat last-updated-y_f8613c25-0490-4b4f-a061-69e23e4f0b73.out
```
last_update
2021-02-11 13:51:40
```
- when the file contains a NULL value it is a potential unused service
```
last_update
NULL
```


