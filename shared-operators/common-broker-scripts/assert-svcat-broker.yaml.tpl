apiVersion: servicecatalog.k8s.io/v1beta1
kind: ServiceBroker
metadata:
  name: ${broker_name}
  namespace: ${smoke_test_namespace}
status:
  lastConditionState: Ready