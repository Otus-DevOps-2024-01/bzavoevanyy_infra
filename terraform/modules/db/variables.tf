variable db_disk_image {
  description = "Disk image for reddit db"
  default = "reddit-db-base"
}
variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}
variable subnet_id {
  description = "Subnet"
}
variable instance_name {
  description = "Instance name"
}
variable instance_tag {
  description = "Instance tag"
}
