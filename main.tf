data "template_file" "apimgmttemplate" {
  template = "${file("${path.module}/templates/api-management.json")}"
}

locals {
  name = "core-api-mgmt-${var.env}"
}

resource "azurerm_subnet" "api-mgmt-subnet" {
  name                 = "core-infra-subnet-apimgmt-${var.env}"
  resource_group_name  = "${var.vnet_rg_name}"
  virtual_network_name = "${var.vnet_name}"
  address_prefix       = "${cidrsubnet("${var.source_range}", 4, var.source_range_index)}"

  lifecycle {
    ignore_changes = "address_prefix"
  }
}

resource "azurerm_template_deployment" "api-managment" {
  template_body       = "${data.template_file.apimgmttemplate.rendered}"
  name                = "${local.name}"
  resource_group_name = "${var.vnet_rg_name}"
  deployment_mode     = "Incremental"

  parameters = {
    location                           = "${var.location}"
    env                                = "${var.env}"
    platform_api_mgmt_name             = "${local.name}"
    platform_api_mgmt_subnetResourceId = "${azurerm_subnet.api-mgmt-subnet.id}"
  }
}
