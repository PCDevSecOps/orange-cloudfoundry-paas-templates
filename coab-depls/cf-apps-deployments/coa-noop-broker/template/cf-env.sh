

# See https://github.com/orange-cloudfoundry/cf-ops-automation/commit/e7c278a91339d92e340a0d426bea7280c3873408
#
# CF_PUSH_OPTIONS= # Use this syntax to avoid using cf push default parameters
echo "Coab-noop is overiding default CF_PUSH_OPTIONS=${CF_PUSH_OPTIONS} with --strategy=null as this option is not supported by CF cli with multiple-apps manifests"
CF_PUSH_OPTIONS="" # Use this syntax to complete cf push default parameters