terraform {
  required_version  = ">= 0.13"

  required_providers {
    yandex = {
      source        = "yandex-cloud/yandex"
      version       = "0.119.0"
    }
  }
  backend "s3" {
    endpoints                   = { s3 = "https://storage.yandexcloud.net" }
    key                         = "terraform/simple_dev/foundation-00/terraform.tfstate"
    region                      = "ru-central1"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    skip_metadata_api_check     = true
  } 
}

provider "yandex" {
  folder_id         = var.folder-id
  token             = var.token-id
  cloud_id          = var.cloud-id
}