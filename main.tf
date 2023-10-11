terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.11.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.5.1"

    }
  }
}

module "mongo" {
  source = "./mongo"
}


module "keycloak" {
  source = "./keycloak"
}


provider "kubernetes" {
  config_path = "~/.kube/config"
}


resource "helm_release" "redis" {
  name       = "huesos"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "redis"
  version    = "18.1.3"
  namespace  = "default"
  wait       = false
  set {
    name  = "replica.replicaCount"
    value = 1
  }

}


resource "helm_release" "kafka" {
  name       = "kakafka"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "kafka"
  version    = "22.1.3"
  namespace  = "default"
  wait       = false
  set {
    name  = "replica.replicaCount"
    value = 1
  }
  set {
    name  = "kraft.enabled"
    value = false
  }

  set {
    name  = "zookeeper.enabled"
    value = true
  }

}





