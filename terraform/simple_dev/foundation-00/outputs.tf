output "private_sub_id" {
  description = "ID of private subnet"
  value = yandex_vpc_subnet.private_a.id
}

output "public_dns_id" {
  description = "ID of public dns zone"
  value = yandex_dns_zone.public_zone.id
}

output "private_dns_id" {
  description = "ID of private dns zone"
  value = yandex_dns_zone.private_zone.id
}

output "sg_id" {
  description = "ID of bastion security group"
  value = yandex_vpc_security_group.bastion_security.id
}

output "external_bastion_ip" {
  description = "external bastion host ip"
  value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}