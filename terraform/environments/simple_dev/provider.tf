terraform {
  required_version  = ">= 0.13"

  required_providers {
    yandex = {
      source        = "yandex-cloud/yandex"
      version       = "0.119.0"
    }
  }
}

provider "yandex" {
  folder_id         = var.folder-id
  token             = var.token-id
  cloud_id          = var.cloud-id
}