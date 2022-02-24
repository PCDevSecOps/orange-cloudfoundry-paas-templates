# backup-restore

## architecture
https://docs.gitlab.com/ee/development/architecture.html

## key 

## automatic backups operation
backups are scheduled every day at 2PM. They are stored under shield minio s3 (shield-s3.internal.paas) on specific buckets.
buckets are created by k8s-gitlab workload (3-gitlab-job-create-bucket-operators.yml)
you can list backup files with the command mc ls <host>/gitlab-backups
```
[2021-03-20 12:02:05 UTC] 189MiB 1616241610_2021_03_20_13.6.1_gitlab_backup.tar
[2021-03-21 12:02:06 UTC] 189MiB 1616328009_2021_03_21_13.6.1_gitlab_backup.tar
[2021-03-22 12:02:19 UTC] 189MiB 1616414411_2021_03_22_13.6.1_gitlab_backup.tar
[2021-03-23 12:01:57 UTC] 189MiB 1616500804_2021_03_23_13.6.1_gitlab_backup.tar
[2021-03-24 12:02:21 UTC] 189MiB 1616587214_2021_03_24_13.6.1_gitlab_backup.tar
[2021-03-25 12:02:34 UTC] 190MiB 1616673612_2021_03_25_13.6.1_gitlab_backup.tar
```

## manual backup operations
documentation is available there : https://docs.gitlab.com/charts/backup-restore/backup.html

on the source gitlab k8s workload, execute following commands in order to backup data : 
```
connect to source k8s-gitlab with log-k8s (hosted on 01-ci-k8s)
kubectl -n gitlab exec <gitlab-task-runner-pod> -it backup-utility
```

on the source gitlab k8s workload, execute following commands in order to backup the key :
```
connect to source k8s-gitlab with log-k8s (hosted on 01-ci-k8s)
kubectl -n gitlab get secrets gitlab-rails-secret -o jsonpath="{.data['secrets\.yml']}" | base64 --decode > secrets.yaml
```
the key is stored on configuration/secrets repository


## restore
documentation is available there : https://docs.gitlab.com/charts/backup-restore/restore.html

on the target gitlab k8s workload, destroy the k8s-gitlab workload and provision it afterwards
retrieve the key from configuration/secrets repository and put it on file system (the file must be called secrets.yaml)
```
connect to target k8s-gitlab with log-k8s (hosted on 01-ci-k8s)
kubectl delete namespace gitlab
kubectl -n gitlab delete secret gitlab-rails-secret 
kubectl -n gitlab create secret generic gitlab-rails-secret --from-file=secrets.yml=secrets.yaml
kubectl -n gitlab delete pods -lapp=sidekiq
kubectl -n gitlab delete pods -lapp=webservice
kubectl -n gitlab delete pods -lapp=task-runner[cible]kubectl -n gitlab get pods -lapp=task-runner
kubectl -n gitlab exec gitlab-task-runner-dcdc4cd59-2st8g -it -- backup-utility --restore -t 1616328009_2021_03_21_13.6.1
kubectl -n gitlab delete pods --all
```

1616328009_2021_03_21_13.6.1 is a backup instance stored under shield minio s3






