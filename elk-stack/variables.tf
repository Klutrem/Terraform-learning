variable "namespace" {
  type    = string
  default = "skyfarm"
}

variable "elasticsearch_values_path" {
  type    = string
  default = "elk-stack/values.yml"
}

variable "elasticsearch_heap" {
  type    = string
  default = "128m"
}

variable "elasticsearch_replicas" {
  type    = number
  default = 1
}

variable "elasticsearch_host" {
  type    = string
  default = "10.105.170.42"
}

variable "elasticsearch_port" {
  type    = string
  default = "9200"
}

variable "elasticsearch_service_type" {
  type    = string
  default = "ClusterIP"
}


variable "kibana_pv_size" {
  type    = string
  default = "1Gi"
}

variable "kibana_service_type" {
  type    = string
  default = "ClusterIP"
}
