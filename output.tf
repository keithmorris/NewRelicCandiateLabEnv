output "app_dns" {
  value = "${azurerm_public_ip.app-pip.fqdn}"
}

output "vm_username" {
  value = "${var.username}"
}
