output "kubeconfig_export_command" {
  value = "'export KUBECONFIG=$PWD/azure/${local_file.file.filename}'"
}
