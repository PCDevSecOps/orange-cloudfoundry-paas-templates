#!/bin/bash
#===========================================================================
# Switch gitlab repositories to k8s
#===========================================================================

#--- Load common parameters and functions
. $(dirname $(which $0))/functions.sh

#--- Switch git remote repositories
SITE=$(getValue ${SHARED_SECRETS} /secrets/site)
OPS_DOMAIN=$(getValue ${SHARED_SECRETS} /secrets/ops_interco/ops_domain)

cd ~/bosh
if [ -d template ] ; then
  cd template
  printf "\n%bSet template git repository...%b\n" "${REVERSE}${YELLOW}" "${STD}"
  if [ "${SITE}" != "fe-int" ] ; then
    GITLAB_TEMPLATE="https://gitlab-gitlab-k8s.${OPS_DOMAIN}/paas_templates_group/paas-templates.git"
  fi

  git remote set-url origin ${GITLAB_TEMPLATE}
  git remote -v
fi

cd ~/bosh
if [ -d secrets ] ; then
  cd secrets
  printf "\n%bSet secrets git repository...%b\n" "${REVERSE}${YELLOW}" "${STD}"
  GITLAB_SECRETS="https://gitlab-gitlab-k8s.${OPS_DOMAIN}/paas_templates_group/paas-templates-secrets.git"
  git remote set-url origin ${GITLAB_SECRETS}
  git remote -v
fi
