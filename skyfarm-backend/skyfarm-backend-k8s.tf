resource "kubernetes_config_map" "skyfarm-config" {
  metadata {
    name      = "skyfarm-config"
    namespace = var.namespace
  }
  data = {
    "SERVER_PORT" : "3000",
    "WEBSOCKET_PORT" : 12121
    #"MONGO_URL" : "mongodb://admin:admin@${kubernetes_service.mongo-ip.spec[0].cluster_ip}:27017",
    "DB_NAME" : "Kubernetes",
    "DB_COLLECTION" : "Workspases",
    "JWT_SECRET" : "PSdH8jmh7JT5cZ59uEm3rtuMm43KIUUe"
  }
}


resource "kubernetes_pod" "skyfarm-backend" {
  metadata {
    name      = "skyfarm-backend"
    namespace = var.namespace
    labels    = { "kubernetes.io/appname" : "skyfarm" }
  }
  spec {
    container {
      name              = "skyfarm-backend"
      image             = "klutrem/skyfarm:jwt"
      image_pull_policy = "Always"
      env_from {
        config_map_ref {
          name = kubernetes_config_map.skyfarm-config.metadata[0].name
        }
      }
      port {
        host_port      = 3000
        container_port = 3000
      }
      port {
        host_port      = 12121
        container_port = 12121
      }
    }
  }
}
