variable "namespace" {
  type    = string
  default = "default"
}


variable "port" {
  type    = number
  default = 27017
}

variable "password" {
  type    = string
  default = "admin"
}

variable "name" {
  type    = string
  default = "admin"
}

variable "label" {
  description = "This is a variable for lable"
  type = object({
    name = string
    app  = string
  })
  default = {
    name = "mongodb"
    app  = "mongo"
  }
}
