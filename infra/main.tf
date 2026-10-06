terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# --------------------------------------------------
# RESOURCE GROUP
# --------------------------------------------------

resource "azurerm_resource_group" "production" {
  name     = "rg-iac-security-production"
  location = "Canada Central"

  tags = {
    environment = "production"
    managed_by  = "terraform"
  }
}

# --------------------------------------------------
# INSECURE STORAGE ACCOUNT
# --------------------------------------------------

resource "azurerm_storage_account" "logs" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.production.name
  location                 = azurerm_resource_group.production.location

  account_tier             = "Standard"
  account_replication_type = "LRS"

  https_traffic_only_enabled       = false
  allow_nested_items_to_be_public  = true
  shared_access_key_enabled        = true
  public_network_access_enabled    = true

  min_tls_version = "TLS1_2"

  tags = {
    environment = "production"
  }
}

# --------------------------------------------------
# NETWORK SECURITY GROUP
# --------------------------------------------------

resource "azurerm_network_security_group" "production" {
  name                = "nsg-production"
  location            = azurerm_resource_group.production.location
  resource_group_name = azurerm_resource_group.production.name
}

# --------------------------------------------------
# DELIBERATELY INSECURE SSH RULE
#
# Anyone on the internet can attempt to connect.
# --------------------------------------------------

resource "azurerm_network_security_rule" "ssh" {
  name                        = "allow-ssh-internet"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"

  source_port_range           = "*"
  destination_port_range      = "22"

  # SECURITY PROBLEM:
  source_address_prefix       = "*"

  destination_address_prefix  = "*"

  resource_group_name         = azurerm_resource_group.production.name
  network_security_group_name = azurerm_network_security_group.production.name
}