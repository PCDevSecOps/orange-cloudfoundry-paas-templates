NoOps broker is a broker which deploys no vms. This supports scalability tests for COAB. See https://github.com/orange-cloudfoundry/cf-ops-automation-broker/issues/38

Since there is no VM, a shared static nested broker (deployed in cloudfoundry along side with the coab noop broker) is used instead. 