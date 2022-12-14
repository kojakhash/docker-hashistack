terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

provider "docker" {}

resource "docker_network" "private_network" {
  name = "bridge_network"
  attachable = true
  driver = "bridge"
}

resource "docker_image" "consul" {
  name         = "hashicorp/consul-enterprise:latest"
  keep_locally = false
}

resource "docker_image" "vault" {
  name         = "hashicorp/vault:latest"
  keep_locally = false
}

resource "docker_image" "fake-service" {
  name         = "nicholasjackson/fake-service:v0.24.2"
  keep_locally = false
}

resource "docker_container" "consul-server1" {
  image = docker_image.consul.image_id
  name  = "consul-server1"
  hostname = "consul-server1"
  env = [
    "VAULT_ADDR=http://vault-server:8200",
    "VAULT_TOKEN=vault-plaintext-root-token",
    "CONSUL_HTTP_ADDR=consul-server1:8500",
    "CONSUL_HTTP_TOKEN=e95b599e-166e-7d80-08ad-aee76e7ddf19"
  ]
  capabilities {
    add = ["IPC_LOCK"]
    drop = []
  }
  ports {
    internal = 8500
    external = 8500
  }
  ports {
    internal = 8600
    external = 8600
    protocol = "tcp"
  }
  ports {
    internal = 8600
    external = 8600
    protocol = "udp"
  }
  volumes {
    host_path = "${var.pwd}/consul/server.json"
    container_path = "/consul/config/server.json"
  }
  volumes {
    host_path = "${var.pwd}/consul/license.hclic"
    container_path = "/consul/config/license.hclic"
  }
  volumes {
    host_path = "${var.pwd}/consul/certs/"
    container_path = "/consul/config/certs/"
  }
  volumes {
    host_path = "${var.pwd}/consul/consul-acl.json"
    container_path = "/consul/config/consul-acl.json"
  }
  networks_advanced {
    name = "${docker_network.private_network.name}"
  }
  command = ["agent","-bootstrap-expect=3"]
}

resource "docker_container" "consul-server2" {
  image = docker_image.consul.image_id
  name  = "consul-server2"
  hostname = "consul-server2"
  env = [
    "VAULT_ADDR=http://vault-server:8200",
    "VAULT_TOKEN=vault-plaintext-root-token",
    "CONSUL_HTTP_ADDR=consul-server2:8500",
    "CONSUL_HTTP_TOKEN=e95b599e-166e-7d80-08ad-aee76e7ddf19"
  ]
  capabilities {
    add = ["IPC_LOCK"]
    drop = []
  }
  volumes {
    host_path = "${var.pwd}/consul/server2.json"
    container_path = "/consul/config/server2.json"
  }
  volumes {
    host_path = "${var.pwd}/consul/license.hclic"
    container_path = "/consul/config/license.hclic"
  }
  volumes {
    host_path = "${var.pwd}/consul/certs/"
    container_path = "/consul/config/certs/"
  }
  volumes {
    host_path = "${var.pwd}/consul/consul-acl.json"
    container_path = "/consul/config/consul-acl.json"
  }
  networks_advanced {
    name = "${docker_network.private_network.name}"
  }
  command = ["agent","-bootstrap-expect=3"]
}

resource "docker_container" "consul-server3" {
  image = docker_image.consul.image_id
  name  = "consul-server3"
  hostname = "consul-server3"
  env = [
    "VAULT_ADDR=http://vault-server:8200",
    "VAULT_TOKEN=vault-plaintext-root-token",
    "CONSUL_HTTP_ADDR=consul-server3:8500",
    "CONSUL_HTTP_TOKEN=e95b599e-166e-7d80-08ad-aee76e7ddf19"
  ]
  capabilities {
    add = ["IPC_LOCK"]
    drop = []
  }
  volumes {
    host_path = "${var.pwd}/consul/server3.json"
    container_path = "/consul/config/server3.json"
  }
  volumes {
    host_path = "${var.pwd}/consul/license.hclic"
    container_path = "/consul/config/license.hclic"
  }
  volumes {
    host_path = "${var.pwd}/consul/certs/"
    container_path = "/consul/config/certs/"
  }
  volumes {
    host_path = "${var.pwd}/consul/consul-acl.json"
    container_path = "/consul/config/consul-acl.json"
  }
  networks_advanced {
    name = "${docker_network.private_network.name}"
  }
  command = ["agent","-bootstrap-expect=3"]
}

resource "docker_container" "consul-client" {
  image = docker_image.consul.image_id
  name  = "consul-client"
  hostname = "consul-client"
  env = [
    "VAULT_ADDR=http://vault-server:8200",
    "VAULT_TOKEN=vault-plaintext-root-token",
    "CONSUL_HTTP_ADDR=consul-client:8500",
    "CONSUL_HTTP_TOKEN=e95b599e-166e-7d80-08ad-aee76e7ddf19"
  ]
  capabilities {
    add = ["IPC_LOCK"]
    drop = []
  }
  volumes {
    host_path = "${var.pwd}/consul/client.json"
    container_path = "/consul/config/client.json"
  }
  volumes {
    host_path = "${var.pwd}/consul/license.hclic"
    container_path = "/consul/config/license.hclic"
  }
  volumes {
    host_path = "${var.pwd}/consul/certs/"
    container_path = "/consul/config/certs/"
  }
  volumes {
    host_path = "${var.pwd}/consul/consul-acl.json"
    container_path = "/consul/config/consul-acl.json"
  }
  networks_advanced {
    name = "${docker_network.private_network.name}"
  }
  command = ["agent"]
}

resource "docker_container" "vault-server" {
  image = docker_image.vault.image_id
  name  = "vault-server"
  hostname = "vault-server"
  entrypoint = ["vault", "server", "-config=/vault/config/local.hcl"]
  env = [
    "VAULT_ADDR=http://0.0.0.0:8200",
    "VAULT_DEV_ROOT_TOKEN_ID=vault-plaintext-root-token",
    "VAULT_TOKEN=vault-plaintext-root-token"
  ]
  capabilities {
    add = ["IPC_LOCK"]
    drop = []
  }
  ports {
    internal = 8200
    external = 8200
  }
  networks_advanced {
    name = "${docker_network.private_network.name}"
  }
  volumes {
    host_path = "${var.pwd}/vault/vault.json"
    container_path = "/consul/config/vault.json"
  }
  volumes {
    host_path = "${var.pwd}/vault/config/"
    container_path = "/vault/config/"
  }
  volumes {
    host_path = "${var.pwd}/consul/certs/"
    container_path = "/consul/config/certs/"
  }
  volumes {
    host_path = "${var.pwd}/consul/consul-acl.json"
    container_path = "/consul/config/consul-acl.json"
  }
}

resource "docker_container" "api" {
  image = docker_image.fake-service.image_id
  name  = "api"
  ports {
    internal = 9091
    external = 9091
  }
  env = [
    "LISTEN_ADDR=0.0.0.0:9091",
    "MESSAGE=API Response",
    "NAME=api",
    "SERVER_TYPE=grpc",
    "VAULT_ADDR=http://vault-server:8200",
    "VAULT_TOKEN=vault-plaintext-root-token",
    "CONSUL_HTTP_ADDR=consul-server1:8500",
    "CONSUL_HTTP_TOKEN=e95b599e-166e-7d80-08ad-aee76e7ddf19"
    ]
  networks_advanced {
    name = "${docker_network.private_network.name}"
  }
  volumes {
    host_path = "${var.pwd}/fake-service/api1.json"
    container_path = "/var/consul/config/api1.json"
  }
  volumes {
    host_path = "${var.pwd}/consul/certs/"
    container_path = "/consul/config/certs/"
  }
  volumes {
    host_path = "${var.pwd}/consul/consul-acl.json"
    container_path = "/consul/config/consul-acl.json"
  }
}

resource "docker_container" "web" {
  image = docker_image.fake-service.image_id
  name  = "web"
  ports {
    internal = 9090
    external = 9090
  }
  env = ["LISTEN_ADDR=0.0.0.0:9090", "UPSTREAM_URIS=grpc://api:9091", "MESSAGE=Hello World", "NAME=web", "SERVER_TYPE=http"]
  networks_advanced {
    name = "${docker_network.private_network.name}"
  }
  volumes {
    host_path = "${var.pwd}/fake-service/web1.json"
    container_path = "/var/consul/config/web1.json"
  }
  volumes {
    host_path = "${var.pwd}/consul/certs/"
    container_path = "/consul/config/certs/"
  }
  volumes {
    host_path = "${var.pwd}/consul/consul-acl.json"
    container_path = "/consul/config/consul-acl.json"
  }
}

resource "docker_container" "web2" {
  image = docker_image.fake-service.image_id
  name  = "web2"
  ports {
    internal = 9090
    external = 9092
  }
  env = ["LISTEN_ADDR=0.0.0.0:9090", "UPSTREAM_URIS=grpc://api:9091", "MESSAGE=Hello World", "NAME=web2", "SERVER_TYPE=http"]
  networks_advanced {
    name = "${docker_network.private_network.name}"
  }
  volumes {
    host_path = "${var.pwd}/fake-service/web2.json"
    container_path = "/var/consul/config/web2.json"
  }
  volumes {
    host_path = "${var.pwd}/consul/certs/"
    container_path = "/consul/config/certs/"
  }
  volumes {
    host_path = "${var.pwd}/consul/consul-acl.json"
    container_path = "/consul/config/consul-acl.json"
  }
}