data "digitalocean_certificate" "diana_ptzo_gdn" {
  name = "diana-ptzo-gdn"
}

resource "helm_release" "traefik_ingress_controller" {
  name       = "traefik-ingress-controller"
  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"
  namespace  = "kube-system"
  version    = "v10.1.1"

  values = [
    "${file("traefik-values.yaml")}"
  ]
}

resource "kubernetes_service" "traefik_ingress_controller" {
  metadata {
    name = "traefik-ingress-controller"
    namespace  = "kube-system"
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
