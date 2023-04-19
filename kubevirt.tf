
provider "kubevirt" {
  config_path = "./kube.conf"
}



resource "kubernetes_service" "lb" {
  metadata {
    name      = "lb"
    namespace = var.namespace
  }
  spec {
    selector = { "kubernetes.io/hostname" : "skyfarm" }
    port {
      port        = 22
      target_port = 22
    }
    type = "NodePort"
  }
}

resource "kubevirt_virtual_machine" "vmt" {
  metadata {
    name      = "vmt"
    namespace = var.namespace
    labels = {
      "kubernetes.io/hostname" : "skyfarm"
    }
  }
  spec {
    data_volume_templates {
      metadata {
        name = "ubuntu-dv"
        labels = {
          "kubernetes.io/hostname" : "skyfarm"
        }
        namespace = var.namespace
      }
      spec {
        source {
          http {
            url = "http://10.244.217.44:9000/public/focal-server-cloudimg-amd64.img"
          }
        }
        pvc {
          access_modes = ["ReadWriteOnce"]
          resources {
            requests = {
              storage = "3Gi"
            }
          }
        }
      }
    }
    run_strategy = "RerunOnFailure"
    template {
      metadata {
        name      = "vmt"
        namespace = var.namespace
        labels = {
          "kubernetes.io/hostname" : "skyfarm"
        }
      }
      spec {
        domain {
          resources {
            requests = {
              memory = "512Mi"
              cpu    = "100m"
            }
          }
          devices {
            disk {
              name = "dv"
              disk_device {
                disk {
                  bus = "virtio"
                }
              }
            }
            disk {
              name = "cloudinitdisk"
              disk_device {
                disk {
                  bus = "virtio"
                }
              }
            }
          }
        }
        volume {
          name = "dv"
          volume_source {
            data_volume {
              name = "ubuntu-dv"
            }
          }
        }
        volume {
          name = "cloudinitdisk"
          volume_source {
            cloud_init_config_drive {
              user_data_base64 = "I2Nsb3VkLWNvbmZpZwogICAgICAgICAgICB1c2VyczoKICAgICAgICAgICAgLSBjaHBhc3N3ZDoKICAgICAgICAgICAgICAgIGV4cGlyZTogZmFsc2UKICAgICAgICAgICAgICBncm91cHM6IHVzZXJzLCBhZG1pbgogICAgICAgICAgICAgIGxvY2tfcGFzc3dkOiBmYWxzZQogICAgICAgICAgICAgIG5hbWU6IGtsdXRyZW0KICAgICAgICAgICAgICBzc2hfYXV0aG9yaXplZF9rZXlzOgogICAgICAgICAgICAgIC0gc3NoLXJzYSBBQUFBQjNOemFDMXljMkVBQUFBREFRQUJBQUFCZ1FESURIRkExVjNpZkFhOTJJYm5XWWdBTmxGVXhzT2orRUV0eWdyR3VvK2dMMXVacGlrNmR4cURRdUFoU2RqaGtNdHkrYmdTUVFvUVFIL0FuNm11REc1S2lOVHQwTU5lMW9XajkwS09kQ3VQMWs0STYvRUk3TkJNc1Jrd0FEU0xZWFNaSjF6M3J3YUZQZ3A3dHF3cHl1eEwwVlg0RlNYTGlLcEl0SFdkUEw3YnppSTdTU21CQnlZSXYzKzNBclNpMVFXQTkzTC9iUkw4NlhzRnpCdW1DSmNJdkdsV0k5TlFlU3ErR2szWGQwQnltaWx4bkN5amdZbSsvOHZIanViVVBiYmh1NDROVnJBZTJxNzdPQXk2aDlvUUNHWGF0a3hQZy9HMzVEbEJETVh5TGl1K2NraGl6S3B1Q2oxWGw2cnlVcE85enJFQ2dDTGxlUlNXT3BBd2kxSVdpM3AvKzJvQ2RlREltbmdzQlpzRkttcGQwT1BhTDNjYzJqcmx5cDVhT0RUcy9qd0tyMndoMHFNelpYMHA4ZW9KbXB0NDg3QmJkS1BOSjAybzkweDg4MmNVOVVEY25uRDl1YlFnR1NkT09tR1VWNkhLNTdBcGN5ZjJpcFJMTEdrYTc1U0tyM3hKVUVGNVpYVSt2UCtUNHdSWDJzSUtUME82MTY3K3NDcklJZ1U9CiAgICAgICAgICAgICAgICB1YnVudHVAc2t5ZmFybQogICAgICAgICAgICAgIC0gc3NoLXJzYSBBQUFBQjNOemFDMXljMkVBQUFBREFRQUJBQUFCZ1FDdHV0THFNRC9YS0FVYVdvTWZlZ3Jzc2xVcXlCeitxdkJTRGhpMGFqM05senlkaUtlK1JaZk1YUndvUjQyTnh1dnF4VENoVVpqMStrQlBXaWdVSkhmbE00cFdhSUlYaGhWeXg3c1FtMkZzRXlsRW1nTEtUSEhwYjJtdStscTdGang4ZDFSRlYvelVtdkVYQjlNcUNtNE45OWpTdTI4OWxobmpicHVhY0pDMTJ6QWdpbGp2YzdyVll1U0RKWkM2Q3NoZDBwYkZvdlV4UEhnRnpnclhJSEZET2dZYVFmVG9KRHZVczIrbjl0S0ZqWExuTThVajIrVGtmQWExOHBpNDYzUHRKNEhUWDY1TTE2RSt6VG9BelBzNkpJRXpBYUxTcUZLNDZxRFFKeDZXLzJJV0RXZkx5c3F6Szd3ZkErS0pndTlxNW9tcDkrTmRENkM4ejlZNUlkbnBKeHVDT1UzSUNCOUtLTkUvaHVjR1JMNVBCREQxYWlrN3pvSU8xT1RPb243OWpTQldDNXVKMWxlczhndDZTUXVuVndQZUlsRVRWb2hZUmhieWhvZU9VWWNwVGFOcFFiaHlKalZFN3FwZ0tLY1RZQzl3eDdMVUExNmVKRjlWK1BucFpsM2k0M3NKaWx1WDQ5RzhGOEN0VXBSK25USWJ1ZTF1UnZvMW85dDdPc2s9CiAgICAgICAgICAgICAgICBrbHV0cmVtQEtsdXRyZW0KICAgICAgICAgICAgICBzdWRvOiBBTEw9KEFMTCkgTk9QQVNTV0Q6QUxMCg=="
            }
          }
        }
      }
    }
  }
}
