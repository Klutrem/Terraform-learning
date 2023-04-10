terraform {

}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "skyfarm" {
  metadata {
    name = "skyfarm"
  }
}

resource "kubernetes_secret" "mongo-credentials" {
  metadata {
    name      = "mongo-credentials"
    namespace = kubernetes_namespace.skyfarm.metadata[0].name
  }
  data = {
    "MONGO_INITDB_ROOT_USERNAME" = "admin"
    "MONGO_INITDB_ROOT_PASSWORD" = "admin"
  }
}

resource "kubernetes_persistent_volume_claim" "mongo-pvc" {
  metadata {
    name      = "mongo-pvc"
    namespace = kubernetes_namespace.skyfarm.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    storage_class_name = kubernetes_persistent_volume.mongo-pv.spec[0].storage_class_name
    volume_name        = kubernetes_persistent_volume.mongo-pv.metadata[0].name
  }
}

resource "kubernetes_persistent_volume" "mongo-pv" {
  metadata {
    name = "mongo-pv"
  }
  spec {
    capacity = {
      storage = "1Gi"
    }
    access_modes                     = ["ReadWriteOnce"]
    storage_class_name               = "standard"
    persistent_volume_reclaim_policy = "Delete"
    persistent_volume_source {
      host_path {
        path = "/tmp/mongodb"
      }
    }
  }
}

resource "kubernetes_pod" "mongo" {
  metadata {
    name      = "mongo"
    namespace = "skyfarm"
    labels = {
      "kubernetes.io/hostname" : "minikube",
      "kubernetes.io/name" : "mongodb"
    }

  }
  spec {
    node_name = "minikube"
    container {
      name  = "mongo"
      image = "mongo"
      env_from {
        secret_ref {
          name = kubernetes_secret.mongo-credentials.metadata[0].name
        }
      }
      port {
        host_port      = 27017
        container_port = 27017
      }
    }
    volume {
      name = kubernetes_persistent_volume_claim.mongo-pvc.metadata[0].name

    }
  }
}

resource "kubernetes_service" "mongo-ip" {
  metadata {
    name      = "mongo-ip"
    namespace = kubernetes_namespace.skyfarm.metadata[0].name
  }
  spec {
    selector = { "kubernetes.io/name" : "mongodb" }
    port {
      port        = 27017
      target_port = 27017
    }
  }

}