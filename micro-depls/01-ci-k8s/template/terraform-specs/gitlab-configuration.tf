#--- Configure GitLab Provider
provider "gitlab" {
    token = "((gitlab_api_token))"
    base_url = "https://gitlab-gitlab-k8s.((/secrets/cloudfoundry_ops_domain))/api/v4/"
}

#--- Add paas-template group
resource "gitlab_group" "paas_templates_group" {
    name = "paas_templates_group"
    path = "paas_templates_group"
    description = "paas_templates_group"
}

#--- Add projects to the group
resource "gitlab_project" "paas_templates_project" {
    name = "paas-templates"
    namespace_id = gitlab_group.paas_templates_group.id
    visibility_level = "private"
}

resource "gitlab_project" "paas_templates_coa" {
    name = "cf-ops-automation"
    namespace_id = gitlab_group.paas_templates_group.id
    visibility_level = "private"
}

resource "gitlab_project" "paas_templates_secrets" {
    name = "paas-templates-secrets"
    namespace_id = gitlab_group.paas_templates_group.id
    visibility_level = "private"
}

resource "gitlab_project" "spring-cloud-config" {
    name = "spring-cloud-config"
    namespace_id = gitlab_group.paas_templates_group.id
    visibility_level = "private"
}


resource "gitlab_project" "paas-templates-archive" {
    name = "paas-templates-archive"
    namespace_id = gitlab_group.paas_templates_group.id
    visibility_level = "private"
}

resource "gitlab_project" "gitops-fluxcd-repo" {
    name = "gitops-fluxcd-repo"
    namespace_id = gitlab_group.paas_templates_group.id
    visibility_level = "private"
    default_branch = "master"
    initialize_with_readme =  "true"
}

resource "gitlab_branch_protection" "gitops-fluxcd-repo-branch-protection" {
  project                      = gitlab_project.gitops-fluxcd-repo.id
  branch                       = "main"
  push_access_level            = "developer"
  merge_access_level           = "developer"
}

#generate a gitlab deploy token
resource "gitlab_deploy_token" "gitops-deploy-token" {
  group      = "paas_templates_group"
  name       = "gitops group deploy token"

  scopes = [ "read_repository" ]
}
