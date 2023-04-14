terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.19.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.7.0"
    }
  }
}

resource "kubernetes_namespace" "skyfarm" {
  metadata {
    name = var.namespace
  }
}

# provider "docker" {}
# resource "docker_image" "mongo" {
#   name = "mongo:latest"
# }

# resource "docker_image" "skyfarm" {
#   name = "klutrem/skyfarm:latest"
# }

# resource "docker_container" "mongo" {
#   image = docker_image.mongo.image_id
#   name  = "mongodb"
#   env   = ["MONGO_INITDB_ROOT_PASSWORD=admin", "MONGO_INITDB_ROOT_USERNAME=admin"]

#   ports {
#     internal = 27017
#     external = 6000
#   }
# }

# resource "docker_container" "skyfarm" {
#   image = docker_image.skyfarm.image_id
#   name  = "skyfarm"
#   env   = ["MONGO_URL=mongodb://admin:admin@localhost:6000", "SERVER_PORT=3000"]
#   ports {
#     internal = 3000
#     external = 3000
#   }
# }
