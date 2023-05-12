variable "namespace" {
  type    = string
  default = "skyfarm"
}


variable "elasticsearch_version" {
  type    = string
  default = "19.6.0"
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


variable "logstash_storage" {
  type    = string
  default = "2Gi"
}

variable "logstash_host" {
  type    = string
  default = "10.105.170.43"
}

variable "logstash_port" {
  type    = string
  default = "8080"
}

variable "logstash_configmap" {
  type    = string
  default = "logstash-cm"
}

variable "kibana_version" {
  type    = string
  default = "10.2.17"
}

variable "logstash_log_host" {
  type    = string
  default = "127.0.0.1"
}

variable "beats_port" {
  type    = string
  default = "5555"
}
