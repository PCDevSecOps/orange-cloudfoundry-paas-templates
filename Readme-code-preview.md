
The `manual-drop` branch contains sanitized version of the code used by our team for running Cf and services.

**This branch is subject to force pushes in the future, and git history rewrites.** 

As the code still contains some secret/non public data, the code preview shared on github is still partial.

The redacted code is replaced by dangling symlink files:

```
$ ls -al bootstrap/tools/bootstrap.sh 
lrwxrwxrwx 1 guillaume guillaume 26 sept. 28 16:56 bootstrap/tools/bootstrap.sh -> temporary-redacted-content
```

You can also see the full list of sanitized files in [./bin/sanitized.sh](./bin/sanitized.sh)

We aim at improving the sanitization process to be more selective, and move out secrets/confidential data our of this repo. See [related issue #66](https://github.com/orange-cloudfoundry/paas-templates/issues/65) 

Please open an issue if you are interested in learning more and you need a more complete and stable private preview copy of this repo.
