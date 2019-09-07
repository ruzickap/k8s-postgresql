resource "kubernetes_namespace" "external-dns" {
  metadata {
    name = "external-dns"
  }
}

resource "kubernetes_secret" "azure-config-file" {
  metadata {
    name      = "azure-config-file"
    namespace = kubernetes_namespace.external-dns.id
  }
  data = {
    "azure.json" = <<EOF
      {
        "tenantId"        : "${var.tenant_id}",
        "subscriptionId"  : "${var.subscription_id}",
        "resourceGroup"   : "${var.resource_group_name}-dns",
        "aadClientId"     : "${var.client_id}",
        "aadClientSecret" : "${var.client_secret}"
      }
    EOF
  }
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "external-dns" {
  depends_on = [kubernetes_secret.azure-config-file]
  name       = "external-dns"
  repository = data.helm_repository.stable.metadata.0.name
  chart      = "external-dns"
  version    = var.helm_external-dns_version
  namespace  = kubernetes_namespace.external-dns.id

  set {
    name  = "provider"
    value = "azure"
  }
  set {
    name  = "azure.secretName"
    value = "azure-config-file"
  }
  set {
    name  = "resourceGroup"
    value = "${var.resource_group_name}-dns"
  }
  set {
    name  = "domainFilters"
    value = "{${var.dns_zone_name}}"
  }
  set {
    name  = "istioIngressGateways"
    value = "{istio-system/istio-ingressgateway}"
  }
  set {
    name  = "interval"
    value = "10s"
  }
  set {
    name  = "policy"
    value = "sync"
  }
  set {
    name  = "rbac.create"
    value = "true"
  }
  set {
    name  = "sources"
    value = "{istio-gateway,service}"
  }
  set {
    name  = "txtOwnerId"
    value = "${var.prefix}-${var.kubernetes_cluster_name}-${replace(var.dns_zone_name, ".", "-")}"
  }
}