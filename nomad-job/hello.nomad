job "nginx-web" {
  datacenters = ["dc1"]
  type = "service"

  group "web-group" {
    count = 1

    task "web" {
      driver = "docker"
      config {
        image = "nginx:latest"
        ports = ["http"]
      }
      resources {
        cpu    = 100
        memory = 128
      }
    }

    network {
      port "http" {
        static = 8080
        to     = 80
      }
    }

  }
}