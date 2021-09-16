terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.58.0"
    }
  }
}

provider "azurerm" {
  features {}
}
