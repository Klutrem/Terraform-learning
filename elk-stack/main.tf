resource "kubernetes_namespace" "skyfarm" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  namespace  = var.namespace
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "elasticsearch"
  values     = [file(var.elasticsearch_values_path)]
  wait       = false
  version    = "19.6.0"

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
  version    = "10.2.17"

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
