resource "helm_release" "keycloak" {
  name       = "keycloak"
  repository = "bitnami"
  chart      = "keycloak"
  wait       = false
  namespace  = var.namespace
  version    = "13.0.1"

  set {
    name  = "postgresql.auth.postgresPassword"
    value = var.establish_connection_password
  }
  set {
    name  = "postgresql.auth.password"
    value = var.postgres_password
  }
  set {
    name  = "auth.adminPassword"
    value = var.admin_password
  }
  set {
    name  = "auth.adminUser"
    value = var.admin_name
  }
}

