The no-op model is designed to have the least consumption of bosh resources (ip, vm, storage) while still exercising bosh director in order to test scalability aspects.

It currently uses the cassandra model scaled down to zero instances in each instance groups. This made it easier as a first step to comply with required manifest sections in [bosh deployment manifest section](http://bosh.io/docs/manifest-v2/) 


```bash
#create service instances
function create_service_instances {
    for i in {15..40}; do 
        cf cs noop-ondemand default gberche-noop-load-test-$i -b osb-cmdb-broker-cf-z1 ;
        sleep 600 
    done
}

function get_orphaned_service_instanes {
    #check number of actual service instances
    find ./int-secrets/coab-depls/ -name enable* | grep x_ | wc -l
    
    #find orphan service instances
    REQUESTED_SERVICE_NAMES=$( cf s | grep noop-ondemand | cut -d ' ' -f 1)
    
    # https://www.gnu.org/software/bash/manual/html_node/Command-Substitution.html#Command-Substitution
    # If the () command substitution appears within double quotes, word splitting and filename expansion are not performed on the results. I.e. each entry is separated by a new line
    REQUESTED_SERVICE_GUIDS="$(echo $REQUESTED_SERVICE_NAMES| xargs -n 1  cf service --guid | sort)" 
    ACTUAL_SERVICE_GUIDS="$(find int-secrets/coab-depls/ -name enable* | grep x_ | cut -d '/' -f 3 |sed 's/x_//' | sort)"
      
      
    # "comm - compare two sorted files line by line"
    # -3     suppress column 3 (lines that appear in both files)
    ORPHAN_SERVICE_GUIDS="$(comm -3 <(echo "$REQUESTED_SERVICE_GUIDS") <(echo "$ACTUAL_SERVICE_GUIDS"))"
}

#Delete orphan services
function delete_orphan_services {
    cd int-secrets
    for s in $ORPHAN_SERVICE_GUIDS ; do rm -rf coab-depls/x_$s; done
    for s in $ORPHAN_SERVICE_GUIDS ; do git add -u coab-depls/x_$s; done
    git commit -m "manually cleaning orphan services"
    git pull --rebase
    git push origin
}
```
