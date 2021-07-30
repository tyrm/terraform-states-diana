resource "digitalocean_vpc" "ptzo_network" {
  name     = "ptzo-network"
  region   = "sfo3"
  ip_range = "172.16.0.0/24"
}
