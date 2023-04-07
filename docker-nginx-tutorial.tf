terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}
resource "docker_image" "mongo" {
  name = "mongo:latest"
}

resource "docker_container" "mongo" {
  image = docker_image.mongo.image_id
  name  = "mongodb"
  env   = ["MONGO_INITDB_ROOT_PASSWORD=admin", "MONGO_INITDB_ROOT_USERNAME=admin"]

  ports {
    internal = 27017
    external = 6000
  }
}
