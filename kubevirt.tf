
provider "kubevirt" {
  config_path = "./kube.conf"
}

resource "kubernetes_secret" "kubevirt-credentials" {
  metadata {
    name      = "kubevirt-credentials"
    namespace = var.namespace
  }
  data = {
    user_data = <<-EOF
                        #cloud-config
                        name: klutrem
                        password: pass
                        ssh_authorized_keys: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCtutLqMD/XKAUaWoMfegrsslUqyBz+qvBSDhi0aj3NlzydiKe+RZfMXRwoR42NxuvqxTChUZj1+kBPWigUJHflM4pWaIIXhhVyx7sQm2FsEylEmgLKTHHpb2mu+lq7Fjx8d1RFV/zUmvEXB9MqCm4N99jSu289lhnjbpuacJC12zAgiljvc7rVYuSDJZC6Cshd0pbFovUxPHgFzgrXIHFDOgYaQfToJDvUs2+n9tKFjXLnM8Uj2+TkfAa18pi463PtJ4HTX65M16E+zToAzPs6JIEzAaLSqFK46qDQJx6W/2IWDWfLysqzK7wfA+KJgu9q5omp9+NdD6C8z9Y5IdnpJxuCOU3ICB9KKNE/hucGRL5PBDD1aik7zoIO1OTOon79jSBWC5uJ1les8gt6SQunVwPeIlETVohYRhbyhoeOUYcpTaNpQbhyJjVE7qpgKKcTYC9wx7LUA16eJF9V+PnpZl3i43sJiluX49G8F8CtUpR+nTIbue1uRvo1o9t7Osk= klutrem@Klutrem"
                        chpasswd: false
                        lock_passwd: false
                        EOF

  }
}



resource "kubernetes_service" "mongo-ip" {
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
    type = "LoadBalancer"
  }
}

resource "kubevirt_virtual_machine" "vmt" {
  metadata {
    name      = "vmt"
    namespace = var.namespace
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
              user_data = <<-EOF
              #cloud-config
              name:klutrem
              password:pass
              ssh_authorized_keys:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCtutLqMD/XKAUaWoMfegrsslUqyBz+qvBSDhi0aj3NlzydiKe+RZfMXRwoR42NxuvqxTChUZj1+kBPWigUJHflM4pWaIIXhhVyx7sQm2FsEylEmgLKTHHpb2mu+lq7Fjx8d1RFV/zUmvEXB9MqCm4N99jSu289lhnjbpuacJC12zAgiljvc7rVYuSDJZC6Cshd0pbFovUxPHgFzgrXIHFDOgYaQfToJDvUs2+n9tKFjXLnM8Uj2+TkfAa18pi463PtJ4HTX65M16E+zToAzPs6JIEzAaLSqFK46qDQJx6W/2IWDWfLysqzK7wfA+KJgu9q5omp9+NdD6C8z9Y5IdnpJxuCOU3ICB9KKNE/hucGRL5PBDD1aik7zoIO1OTOon79jSBWC5uJ1les8gt6SQunVwPeIlETVohYRhbyhoeOUYcpTaNpQbhyJjVE7qpgKKcTYC9wx7LUA16eJF9V+PnpZl3i43sJiluX49G8F8CtUpR+nTIbue1uRvo1o9t7Osk= klutrem@Klutrem"
              chpasswd:false
              lock_passwd:false
              EOF
            }
          }
        }
      }
    }
  }
}
