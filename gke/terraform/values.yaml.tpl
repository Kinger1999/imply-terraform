deployments:
  agents: false
  mysql: false
  minio: false

manager:
  licenseKey: |
    ${license}
  nodeSelector:
    imply.io/type: system
  extraEnv:
  - name: imply_manager_onprem_kubernetes_nodeTolerationKey
    value: imply.io/agent
  kubernetesMode:
    instanceTypeNodeSelectorLabel: imply.io/machine_type
    config:
      dataInstanceTypes: ${dataInstanceTypes}
      queryInstanceTypes: ${queryInstanceTypes}
      masterInstanceTypes: ${masterInstanceTypes}
      druidInstanceTypeConfigurationsVersioned: ${druidInstanceConfig}

druid:
  deepStorage:
    type: google
    password:

zookeeper:
  nodeSelector:
    imply.io/type: system
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - topologyKey: "kubernetes.io/hostname"
          labelSelector:
            matchLabels:
              app: zookeeper
