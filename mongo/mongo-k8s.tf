terraform {

}

resource "kubernetes_secret" "mongo-credentials" {
  metadata {
    name      = "mongo-credentials"
    namespace = var.namespace
  }
  data = {
    "MONGO_INITDB_ROOT_USERNAME" = var.name
    "MONGO_INITDB_ROOT_PASSWORD" = var.password
  }
}



resource "kubernetes_persistent_volume_claim" "mongo-pvc" {
  metadata {
    name      = "mongo-pvc"
    namespace = var.namespace
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

resource "kubernetes_deployment" "mongo" {
  metadata {
    name      = "mongo"
    namespace = var.namespace
    labels    = var.label

  }

  spec {
    selector {
      match_labels = var.label
    }
    template {
      metadata {

        labels = var.label

      }

      spec {
        container {
          name  = "mongodb"
          image = "mongo"
          env_from {
            secret_ref {
              name = kubernetes_secret.mongo-credentials.metadata[0].name
            }
          }
          port {

            container_port = var.port
          }
        }
        volume {
          name = kubernetes_persistent_volume_claim.mongo-pvc.metadata[0].name

        }
      }

    }
  }
}

resource "kubernetes_service" "mongo-ip" {
  metadata {
    name      = "mongo-ip"
    namespace = var.namespace
  }
  spec {
    selector = var.label
    port {
      port        = var.port
      target_port = var.port
    }
  }

}

