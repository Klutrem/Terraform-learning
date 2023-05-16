# resource "kubernetes_namespace" "skyfarm" {
#   metadata {
#     name = var.namespace
#   }
# }

resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  namespace  = var.namespace
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "elasticsearch"
  values     = [file(var.elasticsearch_values_path)]
  wait       = false
  version    = var.elasticsearch_version

  set {
    name  = "master.heapSize"
    value = var.elasticsearch_heap
  }

  set {
    name  = "ingest.heapSize"
    value = var.elasticsearch_heap
  }

  set {
    name  = "coordinating.heapSize"
    value = var.elasticsearch_heap
  }

  set {
    name  = "data.heapSize"
    value = var.elasticsearch_heap
  }

  set {
    name  = "master.replicaCount"
    value = var.elasticsearch_replicas
  }

  set {
    name  = "data.replicaCount"
    value = var.elasticsearch_replicas
  }
  set {
    name  = "service.type"
    value = var.elasticsearch_service_type
  }
  set {
    name  = "coordinating.replicaCount"
    value = var.elasticsearch_replicas
  }

  set {
    name  = "ingest.replicaCount"
    value = var.elasticsearch_replicas
  }

  set {
    name  = "service.ports.restAPI"
    value = var.elasticsearch_port
  }

  set {
    name  = "service.clusterIP"
    value = var.elasticsearch_host
  }
}

resource "helm_release" "kibana" {
  name       = "kibana"
  namespace  = var.namespace
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "kibana"
  wait       = false
  version    = var.kibana_version

  set {
    name  = "persistence.size"
    value = var.kibana_pv_size
  }

  set {
    name  = "service.type"
    value = var.kibana_service_type
  }

  set {
    name  = "elasticsearch.hosts[0]"
    value = var.elasticsearch_host
  }

  set {
    name  = "elasticsearch.port"
    value = var.elasticsearch_port
  }
}


resource "helm_release" "logstash" {
  name       = "logstash"
  namespace  = var.namespace
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "logstash"
  wait       = false
  values     = [file(var.logstash_values_path)]
  version    = var.logstash_version

  set {
    name  = "persistence.size"
    value = var.logstash_storage
  }

  set {
    name  = "service.clusterIP"
    value = var.logstash_host
  }

  set {
    name  = "existingConfiguration"
    value = var.logstash_configmap
  }

  set {
    name  = "enableMultiplePipelines"
    value = true
  }
  # set {
  #   name  = "extraVolumes"
  #   value = <<-EOT
  #   - name : log-volume
  #     persistentVolumeClaim:
  #       claimName: log-pvc
  #   EOT
  # }

  # set {
  #   name  = "extraVolumeMounts"
  #   value = <<-EOT
  #   - name : log-volume
  #     mountPath : /var/log/pods
  #   EOT
  # }
  set {
    name  = "image.debug"
    value = true
  }
}


resource "kubernetes_config_map" "logstash_configmap" {
  metadata {
    name      = var.logstash_configmap
    namespace = var.namespace
  }
  data = {
    "skyfarm.conf" : <<-EOT
    input {
      beats {
        port => 5044
      }
    }

    output {
      if [@metadata][pipeline] {
        elasticsearch {
          hosts => "elasticsearch:9200"
          manage_template => false
          index => "popa" 
          action => "create" 
          pipeline => "%%{[@metadata][pipeline]}" 
          user => "elastic"
          password => "secret"
        }
      } else {
        elasticsearch {
          hosts => "elasticsearch:9200"
          manage_template => false
          index => "huy" 
          action => "create"
          user => "elastic"
          password => "secret"
        }
      }
    }
  EOT

    "pipelines.yml" : <<-EOT
    - pipeline.id: skyfarm
      path.config: "/opt/bitnami/logstash/config/skyfarm.conf"
  EOT

  }
}

resource "kubernetes_persistent_volume" "log-pv" {
  metadata {
    name = "log-pv"
  }
  spec {
    capacity = {
      storage = "1Gi"
    }
    access_modes                     = ["ReadOnlyMany"]
    storage_class_name               = "standard"
    persistent_volume_reclaim_policy = "Delete"
    persistent_volume_source {
      host_path {
        path = "/var/log/pods"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "log-pvc" {
  metadata {
    name      = "log-pvc"
    namespace = var.namespace
  }
  spec {
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    access_modes = ["ReadOnlyMany"]
    volume_name  = "log-pv"
  }
}

resource "kubernetes_config_map" "filebeat-logstash" {
  metadata {
    name      = "filebeat-logstash"
    namespace = var.namespace
  }
  data = {
    "logstash.yml" : <<-EOT
      - module: logstash
        log:
          enabled: true
          var.paths: ["/var/log/logstash.log*"]
        slowlog:
          enabled: true
          var.paths: ["/var/log/logstash-slowlog.log*"]

    EOT
  }
}

resource "kubernetes_config_map" "filebeat-cm" {
  metadata {
    name      = "filebeat-cm"
    namespace = var.namespace
  }
  data = {
    "LOGSTASH_HOST"      = var.logstash_host
    "LOGSTASH_PORT"      = var.logstash_port
    "BEATS_PORT"         = var.beats_port
    "ELASTICSEARCH_HOST" = var.elasticsearch_host
    "ELASTICSEARCH_PORT" = var.elasticsearch_port
    "setup.ilm.enabled" : true
    "filebeat.yml" : <<-EOT
        filebeat.config.modules:
          path: $${path.config}/modules.d/*.yml
          reload.enabled: false
        processors:
          - add_cloud_metadata:
          - add_host_metadata:
          - add_kubernetes_metadata: ~
        # filebeat.inputs:
        #   - type: container
        #     id: skyfarm
        #     stream: stdout
        #     paths:
        #       - /var/log/containers/*.log
        #     processors:
        #     - add_kubernetes_metadata:
        #         in_cluster: true
        filebeat.autodiscover:
          providers:
            - type: kubernetes
              enabled: true
              include_labels: ["app"]
              templates:
                - condition:
                    equals:
                      kubernetes.namespace: ${var.namespace}
                  config:
                    - type: container
                      paths: 
                        - /var/log/containers/*-$${data.kubernetes.container.id}.log  
        # filebeat.autodiscover:
        #   providers:
        #   - type: kubernetes
        #     node: $${NODE_NAME}
        #     hints.enabled: true
        #     hints.default_config:
        #       type: container
        #       paths:
        #         - /var/log/containers/*.log      
        output.logstash:
          hosts: ["logstash:5044"]
        # output.elasticsearch:
        #   hosts: ["elasticsearch:9200"]
        #   index: "%%{[kubernetes.namespace]:filebeat}-%%{[beat.version]}-%%{+yyyy.MM.dd}"
    EOT
  }
}

resource "kubernetes_service_account" "filebeat-serviceacc" {
  metadata {
    name      = "filebeat-service-account"
    namespace = var.namespace
    labels = {
      app = "filebeat"
    }
  }
}

resource "kubernetes_cluster_role" "filebeat-cluster-role" {
  metadata {
    name = "filebeat-cluster-role"
    labels = {
      app = "filebeat"
    }
  }
  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods", "nodes"]
    verbs      = ["get", "watch", "list"]
  }
}

resource "kubernetes_cluster_role_binding" "filebeat-cluster-rb" {
  metadata {
    name = "filebeat-cluster-rb"
    labels = {
      app = "filebeat"
    }
  }
  subject {
    kind      = "ServiceAccount"
    name      = "filebeat-service-account"
    namespace = var.namespace
  }
  role_ref {
    kind      = "ClusterRole"
    name      = "filebeat-cluster-role"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_daemonset" "filebeat" {
  metadata {
    name      = "filebeat"
    namespace = var.namespace
    labels = {
      app = "filebeat"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "filebeat"
      }
    }
    template {
      metadata {
        labels = {
          app = "filebeat"
        }
      }
      spec {
        service_account_name = "filebeat-service-account"
        container {
          name  = "filebeat"
          image = "devopshobbies/filebeat:8.6.2"
          # lifecycle {
          #   post_start {
          #     exec {
          #       command = ["filebeat setup --index-management -E output.logstash.enabled=false -E 'output.elasticsearch.hosts=[\"elasticsearch:9200\"]'"]
          #     }
          #   }
          # }
          env {
            name = "LOGSTASH_HOST"
            value_from {
              config_map_key_ref {
                name = "filebeat-cm"
                key  = "LOGSTASH_HOST"
              }
            }
          }
          env {
            name = "LOGSTASH_PORT"
            value_from {
              config_map_key_ref {
                name = "filebeat-cm"
                key  = "LOGSTASH_PORT"
              }
            }
          }
          env {
            name = "BEATS_PORT"
            value_from {
              config_map_key_ref {
                name = "filebeat-cm"
                key  = "BEATS_PORT"
              }
            }
          }
          env {
            name = "ELASTICSEARCH_HOST"
            value_from {
              config_map_key_ref {
                name = "filebeat-cm"
                key  = "ELASTICSEARCH_HOST"
              }
            }
          }
          env {
            name = "ELASTICSEARCH_PORT"
            value_from {
              config_map_key_ref {
                name = "filebeat-cm"
                key  = "ELASTICSEARCH_PORT"
              }
            }
          }
          env {
            name = "NODE_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }
          volume_mount {
            name       = "log-pvc"
            mount_path = "/var/log/pods"
          }
          volume_mount {
            name       = "config"
            mount_path = "/usr/share/filebeat/filebeat.yml"
            sub_path   = "filebeat.yml"
          }
          args = ["-c", "/usr/share/filebeat/filebeat.yml",
          "-e", ]
          volume_mount {
            name       = "logstash"
            mount_path = "/usr/share/filebeat/modules.d/logstash.yml"
            sub_path   = "logstash.yml"
          }
        }

        volume {
          name = "logstash"
          config_map {
            name = "filebeat-logstash"
          }
        }
        volume {
          name = "log-pvc"
          persistent_volume_claim {
            claim_name = "log-pvc"
          }
        }
        volume {
          name = "config"
          config_map {
            name = "filebeat-cm"
          }
        }
      }
    }
  }
}
