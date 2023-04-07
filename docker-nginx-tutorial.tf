terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

variable "MONGO_INITDB_ROOT_USERNAME" {
  type        = string
  description = "This is an example input variable using env variables."
  default     = "admin"
}
variable "MONGO_INITDB_ROOT_PASSWORD" {
  type        = string
  description = "This is an example input variable using env variables."
  default     = "admin"
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
