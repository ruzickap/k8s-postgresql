data "helm_repository" "repository_kubed" {
  name = "kubed"
  url  = "https://charts.appscode.com/stable/"
}

resource "helm_release" "kubed" {
  name       = "kubed"
  repository = "${data.helm_repository.repository_kubed.metadata.0.name}"
  chart      = "kubed"
  version    = var.helm_kubed_version
  namespace  = "kubed"

  set {
    name  = "apiserver.enabled"
    value = "false"
  }
  set {
    name  = "config.clusterName"
    value = "${var.prefix}-${var.kubernetes_cluster_name}-${replace(var.dns_zone_name, ".", "-")}"
  }
}
