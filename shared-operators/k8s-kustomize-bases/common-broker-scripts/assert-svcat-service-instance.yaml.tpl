apiVersion: servicecatalog.k8s.io/v1beta1
kind: ServiceInstance
metadata:
  name: ${service_instance_name}
  namespace: ${smoke_test_namespace}
status:
  lastConditionState: Ready