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
    value = kubernetes_secret.keycloak-postgresql1.data["POSTGRES_POSTGRES_PASSWORD"]
  }
  set {
    name  = "postgresql.auth.password"
    value = kubernetes_secret.keycloak-postgresql1.data["POSTGRES_PASSWORD"]
  }
  set {
    name  = "auth.adminPassword"
    value = kubernetes_secret.keycloak1.data["KEYCLOAK_ADMIN_PASSWORD"]
  }
  set {
    name  = "auth.adminUser"
    value = kubernetes_secret.keycloak1.data["KEYCLOAK_ADMIN"]
  }

}

resource "kubernetes_secret" "keycloak-postgresql1" {
  metadata {
    name      = "keycloak-postgresql1"
    namespace = var.namespace
  }
  data = {
    POSTGRES_POSTGRES_PASSWORD = "admin"
    POSTGRES_PASSWORD          = "admin"
  }
}

resource "kubernetes_secret" "keycloak1" {
  metadata {
    name      = "keycloak1"
    namespace = var.namespace
  }
  data = {
    KEYCLOAK_ADMIN_PASSWORD    = "admin"
    KEYCLOAK_DATABASE_PASSWORD = "admin"
    KEYCLOAK_ADMIN             = "user"
  }
}
