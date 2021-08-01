# create namespace
resource "kubernetes_namespace" "traefik" {
  metadata {
    name = "traefik"
  }
}

# start ingress controller
resource "helm_release" "traefik_ingress_controller" {
  name       = "traefik-ingress-controller"
  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"
  namespace  = "traefik"
  version    = "v10.1.1"

  values = [
    "${file("traefik-values.yaml")}"
  ]
}

# create digital ocean load balancer
data "digitalocean_certificate" "diana_ptzo_gdn" {
  name = "diana-ptzo-gdn"
}

resource "kubernetes_service" "traefik_ingress_controller" {
  metadata {
    name = "traefik-ingress-controller"
    namespace  = "traefik"
    annotations = {
      "service.beta.kubernetes.io/do-loadbalancer-name" = "diana.ptzo.gdn"
      "service.beta.kubernetes.io/do-loadbalancer-size-slug" = "lb-small"
      "service.beta.kubernetes.io/do-loadbalancer-protocol" = "https"
      "service.beta.kubernetes.io/do-loadbalancer-tls-ports" = "443"
      "service.beta.kubernetes.io/do-loadbalancer-certificate-id" = data.digitalocean_certificate.diana_ptzo_gdn.uuid
      "service.beta.kubernetes.io/do-loadbalancer-redirect-http-to-https" = "true"
    }
  }
  spec {
    selector = {
      "app.kubernetes.io/name" = "traefik"
    }
    port {
      name        = "https"
      port        = 443
      target_port = 8000
    }

    type = "LoadBalancer"
  }
}

data "digitalocean_loadbalancer" "diana_ptzo_gdn" {
  name = "diana.ptzo.gdn"
}

# update dns
data "digitalocean_domain" "ptzo_gdn" {
  name = "ptzo.gdn"
}

resource "digitalocean_record" "diana" {
  domain = data.digitalocean_domain.ptzo_gdn.name
  type   = "A"
  name   = "diana"
  value  = data.digitalocean_loadbalancer.diana_ptzo_gdn.ip
  ttl    = 300
}
