data "digitalocean_kubernetes_versions" "k8s_version" {
  version_prefix = "1.21."
}

resource "digitalocean_kubernetes_cluster" "diana" {
  name     = "diana"
  region   = "sfo3"
  vpc_uuid = digitalocean_vpc.ptzo_network.id

  version = data.digitalocean_kubernetes_versions.k8s_version.latest_version

  maintenance_policy {
    start_time  = "04:00"
    day         = "sunday"
  }

  node_pool {
    name       = "main-pool"
    size       = "s-2vcpu-4gb"
    node_count = 3
  }
}

provider "kubernetes" {
  host             = digitalocean_kubernetes_cluster.diana.endpoint
  token            = digitalocean_kubernetes_cluster.diana.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.diana.kube_config[0].cluster_ca_certificate
  )
}

provider "helm" {
  kubernetes {
    host             = digitalocean_kubernetes_cluster.diana.endpoint
    token            = digitalocean_kubernetes_cluster.diana.kube_config[0].token
    cluster_ca_certificate = base64decode(
      digitalocean_kubernetes_cluster.diana.kube_config[0].cluster_ca_certificate
    )
  }
}
