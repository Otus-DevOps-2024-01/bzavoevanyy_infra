provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

module "vpc" {
  source           = "../modules/vpc"
  vpc_network_name = "reddit_app_prod"
  vpc_subnet_name  = "reddit_app_prod"
}

module "app" {
  source          = "../modules/app"
  public_key_path = var.public_key_path
  app_disk_image  = var.app_disk_image
  subnet_id       = module.vpc.vpc_subnet_id
  instance_name   = "reddit-app-prod"
  instance_tag    = "reddit-app-prod"
}

module "db" {
  source          = "../modules/db"
  public_key_path = var.public_key_path
  db_disk_image   = var.db_disk_image
  subnet_id       = module.vpc.vpc_subnet_id
  instance_name   = "reddit-db-prod"
  instance_tag    = "reddit-db-prod"
}
