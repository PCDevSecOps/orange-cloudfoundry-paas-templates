resource "cloudfoundry_buildpack" "php-buildpack-offline" {
  name = "cached-php-buildpack"
  path = "http://private-s3.internal.paas:9000/cached-buildpacks/php_buildpack-cached-v4.4.27.zip"
  locked = false
  enabled = true
}

resource "cloudfoundry_buildpack" "static-buildpack-offline" {
  name = "cached-static-buildpack"
  path = "http://private-s3.internal.paas:9000/cached-buildpacks/staticfile_buildpack-cached-v1.5.14.zip"
  locked = false
  enabled = true
}

resource "cloudfoundry_buildpack" "ruby-buildpack-offline" {
  name = "cached-ruby-buildpack"
  path = "http://private-s3.internal.paas:9000/cached-buildpacks/ruby_buildpack-cached-v1.8.27.zip"
  locked = false
  enabled = true
}

resource "cloudfoundry_buildpack" "nodejs-buildpack-offline" {
  name = "cached-nodejs-buildpack"
  path = "http://private-s3.internal.paas:9000/cached-buildpacks/nodejs_buildpack-cached-v1.7.37.zip"
  locked = false
  enabled = true
}

resource "cloudfoundry_buildpack" "go-buildpack-offline" {
  name = "cached-go-buildpack"
  path = "http://private-s3.internal.paas:9000/cached-buildpacks/go_buildpack-cached-v1.9.23.zip"
  locked = false
  enabled = true
}

resource "cloudfoundry_buildpack" "python-buildpack-offline" {
  name = "cached-python-buildpack"
  path = "http://private-s3.internal.paas:9000/cached-buildpacks/python_buildpack-cached-v1.7.26.zip"
  locked = false
  enabled = true
}

resource "cloudfoundry_buildpack" "binary-buildpack-offline" {
  name = "cached-binary-buildpack"
  path = "http://private-s3.internal.paas:9000/cached-buildpacks/binary_buildpack-cached-v1.0.36.zip"
  locked = false
  enabled = true
}

resource "cloudfoundry_buildpack" "java-buildpack-offline" {
  name = "cached-java-buildpack"
  path = "http://private-s3.internal.paas:9000/cached-buildpacks/java-buildpack-offline-v4.35.zip"
  locked = false
  enabled = true
}

#FIXME: should also provide offline dotnet-core, nginx, r buildpacks
