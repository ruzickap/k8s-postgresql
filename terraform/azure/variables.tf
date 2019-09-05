variable "admin_username" {
  default = "ubuntu"
}

variable "client_id" {}

variable "client_secret" {}

variable "cloud_platform" {
  default = "azure"
}

variable "dns_zone_name" {
  default = "myexample.dev"
}

variable "helm_cert-manager_version" {
  default = "v0.9.1"
}

variable "helm_external-dns_version" {
  default = "2.5.6"
}

variable "helm_istio_version" {
  default = "1.2.5"
}

variable "helm_kubed_version" {
  default = "0.10.0"
}

variable "kubernetes_cluster_name" {
  description = "Name for the Kubernetes cluster (will be used as part of the doman) [k8s.myexample.dev]"
  default     = "k8s"
}

variable "kubernetes_version" {
  default = "1.14.6"
}

variable "letsencrypt_environment" {
  default = "staging"
}

variable "location" {
  default = "westeurope"
}

variable "prefix" {
  default = "mytest"
}

variable "resource_group_name" {
  default = "terraform_resource_group_name"
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "subscription_id" {}

variable "tags" {
  default = {
    Owner       = "pruzicka"
    Environment = "Testing"
  }
}

variable "tenant_id" {}

variable "vm_disk_size" {
  default = "30"
}

variable "vm_size" {
  default = "Standard_B2s"
}

variable "vm_count" {
  default = 1
}
