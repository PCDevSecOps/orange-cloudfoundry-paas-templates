#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require_relative '../../../../lib/upgrade'

class VSphereActivationEnforcer < Upgrade::BaseActivationEnforcer
  def enable_micro_depls
    micro_depls_deployments = %w[ ] # No specific activation on vsphere in v44.0.0
    micro_depls.enable_deployments(micro_depls_deployments)
  end

  def disable_micro_depls
    micro_depls_deployments = %w[
      internet-relay
    ]
    micro_depls.disable_deployments(micro_depls_deployments)
  end
  def micro_depls_pipelines
    # Nothing on vsphere only in v44
  end

  def enable_master_depls
    master_depls_deployments = %w[ ] # No specific activation on vsphere in v44.0.0
    master_depls.enable_deployments(master_depls_deployments)
  end
  def disable_master_depls
    master_depls_deployments = %w[
      bosh-kubo
      cf-internet-rps
      isolation-segment-internet
      isolation-segment-intranet-2
    ]
    master_depls.disable_deployments(master_depls_deployments)
  end
  def master_depls_pipelines
    # Nothing on vsphere only in v44
  end

  def enable_ops_depls
  end
  def disable_ops_depls
    ops_depls_deployments = %w[
      cassandra
      admlin-ui
      cf-redis
      cf-rabbit
      cloudfoundry-mysql
      guardian-uaa-prod
      guardian-uaa
      neo4j-docker
      mongodb
      memcache
      kafka
      vault
      postgresql-docker
      nfs-volume
    ]
    ops_depls.disable_deployments(ops_depls_deployments)
  end

  def ops_depls_pipelines
    disabled_pipelines = %w[
      recurrent-tasks
    ]
    ops_depls.disable_deployments(disabled_pipelines)
  end
  def ops_depls_cf_apps
    disabled_ops_cf_apps = %w[
      app-sso-sample
      cf-networking-sample-app
      cloudflare-broker
      elpaaso-sandbox
      fpv-intranet-sec-broker
      guardian-uaa-broker-cf
      huawei-cloud-osb
      huawei-cloud-osb-sample-app
      postgresql-docker-broker
      postgresql-docker-test-app
      probe-internet
      sec-group-broker-filter-cf
      subdomain-resa
      users-portal
    ]
    ops_depls.disable_cf_app_deployments(disabled_ops_cf_apps)
  end


  def enable_coab_depls
    # No specific activation on vsphere in v44.0.0
  end
  def disable_coab_depls
    coab_deployments = %w[
      cassandra
      redis
      shield
    ]
    coab_depls.disable_deployments(coab_deployments)
  end
  def coab_depls_pipelines

  end
  def coab_depls_cf_apps
    coab_cf_apps = %w[
      coa-cassandra-broker
      coa-redis-broker
    ]
    coab_depls.disable_cf_app_deployments(coab_cf_apps)
  end


  def enable_kubo_depls

  end
  def disable_kubo_depls

  end
  def kubo_depls_pipelines

  end
end

config_path = ARGV[0]
VSphereActivationEnforcer.new(config_path).run
