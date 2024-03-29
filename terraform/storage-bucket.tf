terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }

  backend "s3" {
    endpoints = {
      s3 = "storage.yandexcloud.net"
    }
    bucket = "<bucket_name>"
    region = "ru-central1"
    key    = "<path_to_state_file_in_bucket>/<state_file_name>.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true # This option is required to describe backend for Terraform version 1.6.1 or higher.
    skip_s3_checksum            = true # This option is required to describe backend for Terraform version 1.6.3 or higher.
  }
}

provider "yandex" {
  token     = "<service_account_OAuth_or_static_key>"
  cloud_id  = "<cloud_ID>"
  folder_id = "<folder_ID>"
  zone      = "<default_availability_zone>"
}
