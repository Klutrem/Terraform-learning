resource "kubernetes_config_map" "skyfarm-config" {
  metadata {
    name      = "skyfarm-config"
    namespace = kubernetes_namespace.skyfarm.metadata[0].name
  }
  data = {
    "SERVER_PORT" : "3000",

    "MONGO_URL" : "mongodb://admin:admin@${kubernetes_service.mongo-ip.spec[0].cluster_ip}:27017",
    "DB_NAME" : "Kubernetes",
    "DB_COLLECTION" : "Workspases"
  }
}


resource "kubernetes_pod" "skyfarm-backend" {
  metadata {
    name      = "skyfarm-backend"
    namespace = kubernetes_namespace.skyfarm.metadata[0].name
    labels    = { "kubernetes.io/hostname" : "minikube" }
  }
  spec {
    node_name = "minikube"

    container {
      name              = "skyfarm-backend"
      image             = "klutrem/skyfarm:latest"
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
