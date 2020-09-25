# Paas-template MariaDB - Galera Cluster 
 - v36.15


# Plans disponibles :
```
                 +----------------------------++----------------------------------------------++     ++----------------------++
                 |         Plan broker        ||            vm-mysql                          ||     ||      plan-mysql      ||
 +--------------++---------------+------+-----++--------------------+-------------------------++-----++----------+-----------++-------+--------+----------------------------------------------------------------------------------
 |   type       ||     Name      | Size | Max ||persistent_disk_type|         vm_type         || FS  ||max_      |mysql_persi|| Price |max_con |             description
 |              ||               |  GB  | Con ||                    |                         ||store||storage_mb|tent_disk  ||       |instance|
 +--------------++---------------+------+-----++--------------------+-------------------------++-----++----------+-----------++-------+--------+----------------------------------------------------------------------------------
 | standard     || small         |    2 |  50 || small-mysql        | small                   ||   6 ||     2048 |      6144 ||    48 |    100 | Dedicated MariaDB Galera Cluster 2GB data storage with 4GB RAM/1CPU
 | standard     || medium        |   33 | 150 || large              | large                   ||  49 ||    33792 |     50176 ||   792 |    200 | Dedicated MariaDB Galera Cluster 33GB data storage with 8GB RAM/2CPU
 | standard     || large         |   66 | 250 || xlarge             | large-mysql             ||  98 ||    67584 |    100352 ||  1584 |    300 | Dedicated MariaDB Galera Cluster 66GB data storage with 8GB RAM/2CPU
 | standard     || xlarge        |  131 | 450 || database           | xlarge-mysql            || 196 ||   134144 |    200704 ||  3144 |    500 | Dedicated MariaDB Galera Cluster 131GB data storage with 16GB RAM/4CPU
 | standard     || xxlarge       |  261 | 700 || xxlarge-performant | xxlarge-mysql           || 391 ||   267264 |    400384 ||  6264 |    750 | Dedicated MariaDB Galera Cluster 261GB data storage with 32GB RAM/8CPU
 | highpower    || powerlarge    |  131 | 700 || xlarge-performant  | xxxlarge-highpowermysql || 196 ||   134144 |    200704 ||  3144 |    750 | Dedicated MariaDB Galera Cluster 131GB data storage (SSD) with 64GB RAM/16CPU
 | highcapacity || capacitylarge |  522 | 700 || datawarehouse      | xlarge-highcapmysql     || 782 ||   534528 |    800768 || 12528 |    750 | Dedicated MariaDB Galera Cluster 522GB data storage with 16GB RAM/4CPU
 +--------------++---------------+------+-----++--------------------+-------------------------++-----++----------+-----------++-------+--------+----------------------------------------------------------------------------------
```

# Impacts
## Type de VM à ajouter dans le Cloud-config pour augmenter la taille du ephemeral_disk (nécessaire à la sauvegarde xtrabackup/MariaBackup)

```yml
vm_types:
- cloud_properties:
    boot_from_volume: true
    ephemeral_disk:
      size: 100000
    instance_type: s3.large.4
    root_disk:
      size: 100
  name: large-mysql
- cloud_properties:
    boot_from_volume: true
    ephemeral_disk:
      size: 200000
    instance_type: s3.xlarge.4
    root_disk:
      size: 200
  name: xlarge-mysql
- cloud_properties:
    boot_from_volume: true
    ephemeral_disk:
      size: 400000
    instance_type: s3.2xlarge.4
    root_disk:
      size: 400
  name: xxlarge-mysql
- cloud_properties:
    boot_from_volume: true
    ephemeral_disk:
      size: 200000
    instance_type: s1.4xlarge
    root_disk:
      size: 200
  name: xxxlarge-highpowermysql
- cloud_properties:
    boot_from_volume: true
    ephemeral_disk:
      size: 800000
    instance_type: s3.xlarge.4
    root_disk:
      size: 800
  name: xlarge-highcapmysql   
```

## Type de VM à ajouter dans le Cloud-config pour (mini 6Go pour la release cf-Mysql)
```yml
disk_types:
- disk_size: 6000
  name: small-mysql
```