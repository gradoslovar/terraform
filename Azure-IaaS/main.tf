provider "azurerm" {
    client_id = "${var.azurerm_client_id}"
    client_secret = "${var.azurerm_client_secret}"
    subscription_id = "${var.azurerm_subscription_id}"
    tenant_id = "${var.azurerm_tenant_id}"
}

resource "azurerm_resource_group" "tfdemo" {
    name = "TerraForm-Demo"
    location = "${var.azurerm_location}"
}

resource "azurerm_virtual_network" "tfvnet" {
    name = "vnet-demo"
    address_space = ["192.168.2.0/24"]
    # address_space = ["${var.address_space}"]
    location = "${var.azurerm_location}"
    resource_group_name = "${azurerm_resource_group.tfdemo.name}"
}

resource "azurerm_subnet" "tfsubnet1" {
    name = "tf-subnet-1"
    resource_group_name = "${azurerm_resource_group.tfdemo.name}"
    virtual_network_name = "${azurerm_virtual_network.tfvnet.name}"
    address_prefix = "192.168.2.16/28"
}

resource "azurerm_public_ip" "publicip" {
    name = "tf-public-ip"
    location = "${var.azurerm_location}"
    resource_group_name = "${azurerm_resource_group.tfdemo.name}"
    public_ip_address_allocation = "static"
}

resource "azurerm_network_interface" "tfinterface" {
    count = "${var.azurerm_instances}"
    name = "tf-interface-${count.index}"
    location = "${var.azurerm_location}"
    resource_group_name = "${azurerm_resource_group.tfdemo.name}"

    ip_configuration {
        name = "demo-ip-${count.index}"
        subnet_id = "${azurerm_subnet.tfsubnet1.id}"
        private_ip_address_allocation = "dynamic"
        # the following resource will be created below in the script
        load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.tfbendpool.id}"]
    }
}

resource "azurerm_lb" "tflb" {
    name = "tfdemo-lb"
    location = "${var.azurerm_location}"
    resource_group_name = "${azurerm_resource_group.tfdemo.name}"

    frontend_ip_configuration {
        name = "lbfrontip"
        public_ip_address_id = "${azurerm_public_ip.publicip.id}"
        private_ip_address_allocation = "dynamic"
    }
}

resource "azurerm_lb_rule" "tflbrule" {
    name = "tfdemo-lb-rule-80-80"
    resource_group_name = "${azurerm_resource_group.tfdemo.name}"
    loadbalancer_id = "${azurerm_lb.tflb.id}"
    backend_address_pool_id = "${azurerm_lb_backend_address_pool.tfbendpool.id}"
    probe_id = "${azurerm_lb_probe.tflbprobe.id}"

    protocol = "tcp"
    frontend_port = "80"
    backend_port = "80"
    frontend_ip_configuration_name = "lbfrontip"

}

resource "azurerm_lb_probe" "tflbprobe" {
    name = "tf-health-probe-80"
    loadbalancer_id = "${azurerm_lb.tflb.id}"
    resource_group_name = "${azurerm_resource_group.tfdemo.name}"
    protocol = "http"
    request_path = "/"
    port = 80
}

resource "azurerm_lb_backend_address_pool" "tfbendpool" {
    name = "tflb-backend-pool"
    resource_group_name = "${azurerm_resource_group.tfdemo.name}"
    loadbalancer_id = "${azurerm_lb.tflb.id}"
}

resource "azurerm_availability_set" "tfavailability" {
    name = "tf-availability-set"
    location = "${var.azurerm_location}"
    resource_group_name = "${azurerm_resource_group.tfdemo.name}"
}

# Generate random id for the storage account name
resource "random_id" "storage_account" {
    prefix = "tf"
    byte_length = "4"
}

resource "azurerm_storage_account" "tfstorage" {
    name = "${lower(random_id.storage_account.hex)}"
    resource_group_name = "${azurerm_resource_group.tfdemo.name}"
    location = "${var.azurerm_location}"
    account_type = "Standard_LRS"
}

resource "azurerm_storage_container" "container" {
    count = "${var.azurerm_instances}"
    name = "tf-storage-container-${count.index}"
    resource_group_name = "${azurerm_resource_group.tfdemo.name}"
    storage_account_name = "${azurerm_storage_account.tfstorage.name}"
}

resource "azurerm_virtual_machine" "tfvm" {
    count = "${var.azurerm_instances}"
    name = "tf-vm-${count.index}"
    location = "${var.azurerm_location}"
    resource_group_name = "${azurerm_resource_group.tfdemo.name}"
    network_interface_ids = ["${element(azurerm_network_interface.tfinterface.*.id, count.index)}"]
    vm_size = "Standard_A0"
    availability_set_id ="${azurerm_availability_set.tfavailability.id}"

    storage_image_reference {
        publisher = "Canonical"
        offer = "UbuntuServer"
        sku = "14.04.2-LTS"
        version = "latest"
    }

    storage_os_disk {
        name = "tf-disk-${count.index}"
        vhd_uri = "${azurerm_storage_account.tfstorage.primary_blob_endpoint}${element(azurerm_storage_container.container.*.name, count.index)}/mydisk.vhd"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true

    os_profile {
        computer_name = "tf-instance-${count.index}"
        admin_username = "nenad"
        admin_password = "${var.azurerm_vm_admin_password}"
        custom_data = "${base64encode(file("${path.module}/templates/install.sh"))}"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }
}

output "public_ip" {
    value = "${azurerm_public_ip}"
}

