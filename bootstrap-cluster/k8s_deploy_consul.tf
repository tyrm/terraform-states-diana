resource "helm_release" "consul" {
  name       = "consul"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "consul"
  version    = "0.32.1"

  values = [
    "${file("consul-values.yaml")}"
  ]
}
