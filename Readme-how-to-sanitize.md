# How to sanitize paas-template

 1. make a new clone of paas-template as some files are deleted
 2. go into the paas-template clone
 3. go into bin directory and run these scripts
  3.1 ./install-git-secrets.sh (install git-secret ie git-clone)
  3.2 ./security-check.sh  (can be run multiple time when file are updated)
  3.3 ./sanitized.sh (remove files that are not safe to distribute)
  3.4 ./compress.sh (create a tarball, ready to share) 

