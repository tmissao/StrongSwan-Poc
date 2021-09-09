terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.58.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "33d7eadb-fb41-4ef5-9c37-0d67c95a1e70"
  features {}
}