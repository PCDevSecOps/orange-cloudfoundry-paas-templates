#!/usr/bin/env bash

. ./load-git-secrets-env.sh
git clone https://github.com/awslabs/git-secrets.git ${GIT_SECRET_PATH}

git-secrets --install ..

../.git-secret-config.sh



