# inception instance recreation

This document is a guideline for recreating `inception` instance, that should be used to access and manage when `bosh-cli` is not available.  
Recreation allows to maitain `inception` instance with latest stemcell and clis versions.

## Prerequisites

- From **jumpbox** instance, you have to get last updates from `template` and `secrets` repositories (admin scripts are based on)

  `clone method`

  ```bash
  $ rm -fr ~/bosh/template ~/bosh/secrets
  $ git clone <paas_template_url> ~/bosh/template
  $ git clone <secrets_url> ~/bosh/secrets
  ```

  `pull method` (if local repositories exists and set to target remote repository)

  ```bash
  $ cd ~/bosh/secrets ; git remote -v
  $ git pull --rebase ; git status
  $ cd ~/bosh/template ; ; git remote -v
  $ git checkout reference ; git pull --rebase ; git status
  ```

## Recreate inception instance

  ```bash
  $ ~/bosh/template/admin/recreate-inception.sh
  ```

>**Note:**  
> You can use a specific proxy with `-p` or `--proxy` option.  
> If not, script uses `internet proxy` from distribution.

## Set clis and tools on inception instance

- Connect to `inception` instance

  ```bash
  $ ssh inception@<inception internal ip> -i ~/bosh/secrets/shared/keypair/inception.pem
  ```
- Copy `set-env.sh` content to inception instance

- Set `inception` instance environment

  ```bash
  $ set-env.sh
  ```

>**Note:**  
> To use tools, you must clone `secrets` repository to `~/bosh/secrets`