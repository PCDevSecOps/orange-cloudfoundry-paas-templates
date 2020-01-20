#!/bin/bash

echo "downloading dora from cf-acceptance test repo"

git clone https://github.com/cloudfoundry/cf-acceptance-tests
cd cf-acceptance-tests
git checkout 2.4.0
cd assets/dora/
cp -r . ${GENERATE_DIR}/cf-autoscaler-sample-app/

echo "creating CF pre-requisite"
cf create-space $CF_SPACE -o $CF_ORG

# add config.json
cat - > $GENERATE_DIR/config.json <<EOF
{  
   "instance_max_count":5,
   "instance_min_count":2,
   "scaling_rules":[  

      {  
         "adjustment":"+1",
         "breach_duration_secs":120,
         "cool_down_secs":60,
         "metric_type":"throughput",
         "operator":">",
         "threshold":30
      },

      {  
         "adjustment":"-1",
         "breach_duration_secs":120,
         "cool_down_secs":60,
         "metric_type":"throughput",
         "operator":"<",
         "threshold":90
      },
      {  
         "adjustment":"+1",
         "breach_duration_secs":600,
         "cool_down_secs":300,
         "metric_type":"memoryutil",
         "operator":">",
         "threshold":90
      },
      {  
         "adjustment": "-1",
         "breach_duration_secs":600,
         "cool_down_secs":300,
         "metric_type":"memoryutil",
         "operator":"<",
         "threshold":30
      }
   ]
}
EOF

#cf bind-security-group wide-open $CF_ORG $CF_SPACE

cf target -s "$CF_SPACE" -o "$CF_ORG"
cf delete-service sample-autoscaler-service -f  #deleting so the bind with parameter is made for each cf push
cf create-service autoscaler autoscaler-free-plan sample-autoscaler-service

cf bind-service cf-autoscaler-sample-app sample-autoscaler-service -c ${GENERATE_DIR}/config.json

cat ${GENERATE_DIR}/config.json