data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

resource "azurerm_kubernetes_cluster" "kubernetes_cluster" {
  name                = "${var.prefix}-${var.kubernetes_cluster_name}-${replace(var.dns_zone_name, ".", "-")}"
  location            = var.location
  kubernetes_version  = var.kubernetes_version
  resource_group_name = var.resource_group_name
  dns_prefix          = var.kubernetes_cluster_name

  linux_profile {
    admin_username = var.admin_username

    ssh_key {
      key_data = "${file("${var.ssh_public_key}")}"
    }
  }

  agent_pool_profile {
    name            = "${var.prefix}${var.kubernetes_cluster_name}"
    count           = var.vm_count
    vm_size         = var.vm_size
    os_type         = "Linux"
    os_disk_size_gb = var.vm_disk_size
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  tags = var.tags
}

resource "local_file" "file" {
  content  = azurerm_kubernetes_cluster.kubernetes_cluster.kube_config_raw
  filename = "../kubeconfig_${var.prefix}-${var.kubernetes_cluster_name}-${replace(var.dns_zone_name, ".", "-")}"
}
