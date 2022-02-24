# documentation

## content
```
.
├── manual-load-pipeline.sh
├── migrate_coab_pipeline.sh
├── migrate_coab_pipeline_test.sh
├── model-migration-pipeline.yml
├── pipeline-vars-tpl.yml
```

- manual-load-pipeline.sh is a script in order to ease the pipeline setup (quick feedback)
- migrate_coab_pipeline.sh is the script that performs migration plan (build function) and migration apply (migrate function). Is is called by the pipeline and it operates on four services : 
    - cf-mysql
    - mongodb
    - cf-rabbit
    - redis

The script generates working files on /tmp.
 
- migrate_coab_pipeline_test.sh is a test script that tests (see test.md) and calls the migrate_coab_pipeline.sh script : 
    - local test against generated data (cf-mysql service) =>  ./migrate_coab_pipeline_test.sh
    - remote test against real data on BRMC-INT (cf-mysql service) =>  ./migrate_coab_pipeline_test.sh -r 
    - remote test against real data on <GIT_REPOSITORY> (cf-mysql service) =>  ./migrate_coab_pipeline_test.sh -r -p <GIT_REPOSITORY>
    - remote test against real data on <GIT_REPOSITORY> (mongodb service) => ./migrate_coab_pipeline_test.sh -r -p <GIT_REPOSITORY> -b feature-coabdepls-mongodb-serviceinstances

- model-migration-pipeline.yml is a pipeline concourse made of three jobs per service : 
    - a daily backup job which backups service instance branch with a backup prefix configured in secrets repository.
    - a daily plan job which plans the migration based on the reference branch configured in secrets repository
    - [/!\]a manual apply job which applies the migration based on the reference branch. This job destroys the service instance branch. 

- pipeline-vars-tpl.yml is a spruce files which holds variables for the concourse pipeline
    - paas-templates-reference-branch: holds the reference branch on which the migration is based
    - cf-mysql-service-instances-branch: holds the cf-mysql service instances branch
    - cf-rabbit-service-instances-branch: holds the cf-rabbit service instances branch
    - mongodb-service-instances-branch: holds the mongodb service instances branch
    - redis-service-instances-branch: holds the redis service instances branch

## improvements
/!\The branch names can be fully configured in secrets repository. Nevertheless there are discovered in migrate_coab_pipeline.sh by following a naming convention.
    - prefix => feature-coabdepls-
    - suffix => -serviceinstances
/!\migrate_coab_pipeline.sh holds the hard coded list of services and their relates alias
    - cf-mysql#y
    - cf-rabbit#r
    - redis#e
    - mongodb#m
/!\migrate_coab_pipeline.sh performs plan (build) and apply (migrate) operations on all services each time the script is called
