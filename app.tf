data "template_file" "could-init" {
    template = "${file("cloud-init.sh")}"
    vars = {
        pw_expiration = "${var.expiration}"
        username = "${var.username}"
        ssh_key = "${file("ese_rsa.pub")}"
        create = "${azurerm_storage_blob.create.url}"
        salesmanager = "${azurerm_storage_blob.salesmanager.url}"
    }
}

resource "azurerm_network_interface" "app-ext-nic" {
    name                = "${var.rg_prefix}-app-ext-nic"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.rg.name}"
    network_security_group_id = "${azurerm_network_security_group.app-ext-nsg.id}"

    ip_configuration {
        name                          = "${var.rg_prefix}-app-ext-ipconfig"
        subnet_id                     = "${azurerm_subnet.external-subnet.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${azurerm_public_ip.app-pip.id}"
    }
}

resource "azurerm_virtual_machine" "app" {
    name                                = "${local.cname}-${var.rg_prefix}-app-vm"
    location                            = "${var.location}"
    resource_group_name                 = "${azurerm_resource_group.rg.name}"
    vm_size                             = "${var.vm_size}"
    primary_network_interface_id        = "${azurerm_network_interface.app-ext-nic.id}"
    network_interface_ids               = ["${azurerm_network_interface.app-ext-nic.id}"]
    delete_os_disk_on_termination       = true
    delete_data_disks_on_termination    = true
    tags                                = "${var.tags}"

    storage_image_reference {
        publisher = "${var.image_publisher}"
        offer     = "${var.image_offer}"
        sku       = "${var.image_sku}"
        version   = "${var.image_version}"
    }

    storage_os_disk {
        name              = "${var.hostname}-app-osdisk"
        managed_disk_type = "Standard_LRS"
        caching           = "ReadWrite"
        create_option     = "FromImage"
    }

    os_profile {
        computer_name   = "${var.hostname}"
        admin_username  = "${var.admin_username}"
        custom_data     = "${data.template_file.could-init.rendered}"
    }

    os_profile_linux_config {
        disable_password_authentication = true

        ssh_keys = [{
            path     = "/home/${var.admin_username}/.ssh/authorized_keys"
            key_data = "${file("~/.ssh/id_rsa.pub")}"
        }]
    }

    boot_diagnostics {
        enabled     = true
        storage_uri = "${azurerm_storage_account.stor.primary_blob_endpoint}"
    }

    connection {
        type            = "ssh"
        user            = "${var.username}"        
        host            = "${azurerm_public_ip.app-pip.fqdn}"
        private_key     = "${file("ese_rsa.pub")}"
        timeout         = "30m"
    }

    provisioner "remote-exec" {
        inline = [
            "sleep 12m",
            "cloud-init status --wait",
            "sudo shutdown -r 1"
        ]
    }

    provisioner "local-exec" {
        command = "osascript -e 'display notification \"Lab VM for ${var.username} is ready\" with title \"Deployment Complete\" sound name \"Basso\"'"
    }
}