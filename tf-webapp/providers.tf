terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.8.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
  }
}

provider "random" {
  # Configuration options
}

provider "azurerm" {
  features {}
}
