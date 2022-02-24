# Apply from CLI
## Generate tfvars.json
    cd preprod/micro-depls/terraform-config
    spruce merge --prune meta --prune secrets ../../secrets/shared/secrets.yml secrets/secrets.yml secrets/meta.yml template/terraform-tpl.tfvars.yml | spruce json > secrets/terraform.tfvars.json
## Plan
    terraform plan -var-file=secrets/terraform.tfvars.json -state=secrets/terraform.tfstate spec
## Apply
    terraform apply -var-file=secrets/terraform.tfvars.json -state=secrets/terraform-config/terraform.tfstate spec
