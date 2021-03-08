echo "Removing cflinuxfs2 buildpacks"
cf delete-buildpack staticfile_buildpack -s cflinuxfs2  -f
cf delete-buildpack java_buildpack  -s cflinuxfs2 -f
cf delete-buildpack ruby_buildpack -s cflinuxfs2 -f
cf delete-buildpack dotnet_core_buildpack  -s cflinuxfs2 -f
cf delete-buildpack nodejs_buildpack  -s cflinuxfs2 -f
cf delete-buildpack go_buildpack  -s cflinuxfs2 -f
cf delete-buildpack python_buildpack  -s cflinuxfs2 -f
cf delete-buildpack php_buildpack  -s cflinuxfs2 -f
cf delete-buildpack binary_buildpack  -s cflinuxfs2 -f
