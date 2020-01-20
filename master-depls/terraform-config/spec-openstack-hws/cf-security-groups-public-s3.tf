resource "cloudfoundry_sec_group" "sec_group_public_s3_services" {
  name = "public-s3-services"
  on_staging = false
  on_running = true
  rules {
    protocol = "tcp"
    destination = "192.168.99.89/32"
    ports = "443"
    log = false
    description = "https access to public S3"
  }
}


resource "cloudfoundry_sec_group" "sec_group_public_s3_iam" {
  name = "public-s3-iam"
  on_staging = false
  on_running = true
  rules {
    protocol = "tcp"
    destination = "192.168.99.89/32"
    ports = "8600"
    log = true
    description = "https access to public S3 IAM"
  }
}
