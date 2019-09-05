resource "kubernetes_namespace" "namespace_cert-manager" {
  metadata {
    labels = {
      "certmanager.k8s.io/disable-validation" = "true"
    }
    name = "cert-manager"
  }
}

data "http" "crd_cert-manager" {
  url = "https://raw.githubusercontent.com/jetstack/cert-manager/release-0.9/deploy/manifests/00-crds.yaml"
}

resource "null_resource" "cert-manager" {
  depends_on = [kubernetes_namespace.namespace_cert-manager]
  triggers = {
    template_file_cert-manager_application_sha1 = "${sha1("${data.http.crd_cert-manager.body}")}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${var.kubeconfig} -f ${data.http.crd_cert-manager.url}"
  }
}

data "helm_repository" "repository_cert-manager" {
  name = "cert-manager"
  url  = "https://charts.jetstack.io"
}

resource "helm_release" "cert-manager" {
  depends_on = [null_resource.cert-manager]
  name       = "cert-manager"
  repository = "${data.helm_repository.repository_cert-manager.metadata.0.name}"
  chart      = "cert-manager"
  version    = var.helm_cert-manager_version
  namespace  = kubernetes_namespace.namespace_cert-manager.id
}


############################
# Certificates
############################

resource "kubernetes_secret" "example" {
  metadata {
    name      = "azuredns-config"
    namespace = kubernetes_namespace.namespace_cert-manager.id
  }
  data = {
    CLIENT_SECRET = var.client_secret
  }
}

data "template_file" "cert-manager-clusterissuer" {
  template = file("${path.module}/files/cert-manager-${var.cloud_platform}-clusterissuer.yaml.tmpl")
  vars = {
    clientID          = var.client_id
    hostedZoneName    = var.dns_zone_name
    resourceGroupName = var.resource_group_name
    subscriptionID    = var.subscription_id
    tenantID          = var.tenant_id
  }
}

resource "null_resource" "cert-manager-clusterissuer" {
  depends_on = [helm_release.cert-manager]

  triggers = {
    template_file_cert-manager-clusterissuer_sha1 = "${sha1("${data.template_file.cert-manager-clusterissuer.rendered}")}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${var.kubeconfig} -f -<<EOF\n${data.template_file.cert-manager-clusterissuer.rendered}\nEOF"
  }
}

data "template_file" "cert-manager-certificate" {
  template = file("${path.module}/files/cert-manager-${var.cloud_platform}-certificate.yaml.tmpl")
  vars = {
    dnsName                 = var.dns_zone_name
    letsencrypt_environment = var.letsencrypt_environment
  }
}

resource "null_resource" "cert-manager-certificate" {
  depends_on = [null_resource.cert-manager-clusterissuer]

  triggers = {
    template_file_cert-manager-certificate_sha1 = "${sha1("${data.template_file.cert-manager-certificate.rendered}")}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${var.kubeconfig} -f -<<EOF\n${data.template_file.cert-manager-certificate.rendered}\nEOF"
  }
}
