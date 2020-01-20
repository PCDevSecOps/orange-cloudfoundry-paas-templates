#--- retrieve minio password
data "credhub_value" "minio_secret" {
  name = "/micro-bosh/minio-private-s3/s3_secretkey"
}

resource "cloudfoundry_buildpack" "php-buildpack-offline" {
  name = "cached-php-buildpack"
  path = "http://private-s3.internal.paas:9000/cached-buildpacks/php_buildpack-cached-v4.4.2.zip"
  position = 33
  locked = false
  enabled = true
}

resource "cloudfoundry_buildpack" "static-buildpack-offline" {
  name = "cached-static-buildpack"
  path = "http://private-s3.internal.paas:9000/cached-buildpacks/staticfile_buildpack-cached-v1.5.1.zip"
  position = 34
  locked = false
  enabled = true
}

resource "cloudfoundry_buildpack" "ruby-buildpack-offline" {
  name = "cached-ruby-buildpack"
  path = "http://private-s3.internal.paas:9000/cached-buildpacks/ruby_buildpack-cached-v1.8.2.zip"
  position = 35
  locked = false
  enabled = true
}

resource "cloudfoundry_buildpack" "nodejs-buildpack-offline" {
  name = "cached-nodejs-buildpack"
  path = "http://private-s3.internal.paas:9000/cached-buildpacks/nodejs_buildpack-cached-v1.7.4.zip"
  position = 35
  locked = false
  enabled = true
}

resource "cloudfoundry_buildpack" "go-buildpack-offline" {
  name = "cached-go-buildpack"
  path = "http://private-s3.internal.paas:9000/cached-buildpacks/go_buildpack-cached-v1.9.3.zip"
  position = 36
  locked = false
  enabled = true
}

resource "cloudfoundry_buildpack" "python-buildpack-offline" {
  name = "cached-python-buildpack"
  path = "http://private-s3.internal.paas:9000/cached-buildpacks/python_buildpack-cached-v1.7.2.zip"
  position = 37
  locked = false
  enabled = true
}

resource "cloudfoundry_buildpack" "binary-buildpack-offline" {
  name = "cached-binary-buildpack"
  path = "http://private-s3.internal.paas:9000/cached-buildpacks/binary_buildpack-cached-v1.0.35.zip"
  position = 38
  locked = false
  enabled = true
}

resource "cloudfoundry_buildpack" "java-buildpack-offline" {
  name = "cached-java-buildpack"
  path = "http://private-s3.internal.paas:9000/cached-buildpacks/java-buildpack-offline-v4.26.zip"
  position = 39
  locked = false
  enabled = true
}

#FIXME: should also provide offline dotnet-core, nginx, r buildpacks
