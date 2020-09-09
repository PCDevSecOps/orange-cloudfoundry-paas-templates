resource "cloudfoundry_env_var_group" "staging_env_var_group" {
  env_var {
    key = "http_proxy"
    value = "http://system-internet-http-proxy.internal.paas:3128"
    running = false
    staging = true
  }
  env_var {
    key = "https_proxy"
    value = "http://system-internet-http-proxy.internal.paas:3128"
    running = false
    staging = true
  }
}
