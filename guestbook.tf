
resource "kubernetes_pod" "redis" {
  metadata {
    name = "redis-leader"
    labels = {
      "app"  = "redis"
      "role" = "leader"
      "tier" = "backend"
    }
  }
  spec {
    container {
      name  = "leader"
      image = "docker.io/redis:6.0.5"
      resources {
        requests = {
          "cpu"    = "100m"
          "memory" = "100Mi"
        }
      }
      port {
        container_port = 6379
      }
    }
  }
}

resource "kubernetes_service" "redis-leader" {
  metadata {
    name = "redis-leader"
    labels = {
      "app"  = "redis"
      "role" = "leader"
      "tier" = "backend"
    }
  }
  spec {
    port {
      port        = 6379
      target_port = 6379
    }
    selector = {
      "app"  = "redis"
      "role" = "leader"
      "tier" = "backend"
    }
  }
}

resource "kubernetes_pod" "redis-follower" {
  metadata {
    name = "redis-follower"
    labels = {
      "app"  = "redis"
      "role" = "follower"
      "tier" = "backend"
    }
  }
  spec {
    container {
      name  = "follower"
      image = "gcr.io/google_samples/gb-redis-follower:v2"
      resources {
        requests = {
          "cpu"    = "100m"
          "memory" = "100Mi"
        }
      }
      port {
        container_port = 6379
      }
    }
  }

}

resource "kubernetes_service" "redis-follower" {
  metadata {
    name = "redis-follower"
    labels = {
      "app"  = "redis"
      "role" = "follower"
      "tier" = "backend"
    }
  }
  spec {
    port {
      port        = 6379
      target_port = 6379
    }
    selector = {
      "app"  = "redis"
      "role" = "follower"
      "tier" = "backend"
    }
  }
}


resource "kubernetes_pod" "guestbook-frontend" {
  metadata {
    name = "guestbook-frontend"
    labels = {
      "app"  = "guestbook"
      "tier" = "frontend"
    }
  }
  spec {
    container {
      name  = "php-redis"
      image = "gcr.io/google_samples/gb-frontend:v5"
      env {
        name  = "GET_HOSTS_FROM"
        value = "dns"
      }
      resources {
        requests = {
          "cpu"    = "100m"
          "memory" = "100Mi"
        }
      }
      port {
        container_port = 80
      }
    }
  }
}

resource "kubernetes_service" "frontend-service" {
  metadata {
    name = "frontend"
    labels = {
      "app"  = "guestbook"
      "tier" = "frontend"
    }
  }
  spec {
    type = "nodeport"
    port {
      port        = 80
      target_port = 80
    }
    selector = {
      "app"  = "guestbook"
      "tier" = "frontend"
    }
  }
}
