## shield v8 restore
shield v8 is a fs backuped (sqllite 3 database)
first, you must retrieve fixed key from secrets repository
second, you must execute the restore-shield.sh script from docker-bosh-cli (replace line 67 and 68 with the values found in secrets repository) 
third, you must connect to the shield VM and execute following procedure
```bash
monit stop all
/var/vcap/packages/sqlite3/bin/sqlite3 /tmp/work/shield.db
sqlite> .mode insert
sqlite> .output dump_all.sql
sqlite> .dump
sqlite> .exit
cat dump_all.sql | grep -v TRANSACTION | grep -v ROLLBACK | grep -v COMMIT > dump_all_notrans.sql
rm /var/vcap/store/shield/shield.db
/var/vcap/packages/sqlite3/bin/sqlite3 /var/vcap/store/shield/shield.db ".read dump_all_notrans.sql"
chown vcap:vcap /var/vcap/store/shield/shield.db
monit start all
```