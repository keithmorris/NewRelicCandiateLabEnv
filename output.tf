output "app_dns" {
  value = "${azurerm_public_ip.app-pip.fqdn}"
}

output "username" {
  value = "${var.username}"
}
