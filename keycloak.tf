provider "helm" {
  kubernetes {
    config_path = "./kube.conf"
  }
}

resource "helm_release" "keycloak" {
  name       = "keycloak"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "keycloak"
  wait       = false
  namespace  = var.namespace

  set {
    name  = "postgresql.auth.postgresPassword"
    value = "admin"
  }
  set {
    name  = "postgresql.auth.password"
    value = "admin"
  }
  set {
    name  = "auth.adminPassword"
    value = "admin"
  }
  set {
    name  = "auth.adminUser"
    value = "admin"
  }
}

# resource "kubernetes_secret" "fuck-keycloak-postgresql" {
#   metadata {
#     name      = "fuck-keycloak-postgresql"
#     namespace = var.namespace
#   }
#   data = {
#     POSTGRES_POSTGRES_PASSWORD = "admin"
#     POSTGRES_PASSWORD          = "admin"
#     KEYCLOAK_DATABASE_PASSWORD = "admin"
#     postgres-password          = "admin"
#     password                   = "admin"
#     admin-password             = "admin"
#   }
# }

# resource "kubernetes_secret" "fuck-keycloak" {
#   metadata {
#     name      = "fuck-keycloak"
#     namespace = var.namespace
#   }
#   data = {
#     KEYCLOAK_ADMIN_PASSWORD    = "admin"
#     KEYCLOAK_DATABASE_PASSWORD = "admin"
#     admin-password             = "admin"
#   }
# }
