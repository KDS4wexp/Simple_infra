data "yandex_client_config" "client" {}

provider "yandex" {
  
}

locals {
  network_subnets = flatten([
    for network_key, network in var.networks : [
      for subnet_key, subnet in network.subnets : {
        network_key     = network_key
        subnet_key      = subnet_key
        name            = subnet.name
        v4_cidr_blocks  = subnet.v4_cidr_blocks
        zone            = subnet.zone
        network_id      = yandex_vpc_network.network[network_key].id
      }
    ]
  ])

  network_external_ips = flatten([
    for network_key, network in var.networks : [
      for external_ip_key, external_ip in network.external_ips : {
        network_key     = network_key
        external_ip_key = external_ip_key
        name            = external_ip.name
        zone_id         = external_ip.zone_id
      }
    ]
  ])
}

resource "yandex_vpc_network" "network" {
  for_each = try(var.networks, {})
  name                  = each.value.name
  folder_id             = data.yandex_client_config.client.folder_id
}

resource "yandex_vpc_subnet" "subnet" {
  for_each = tomap({
    for subnet in local.network_subnets : "${subnet.network_key}.${subnet.subnet_key}" => subnet
  })
  name                  = each.value.name
  v4_cidr_blocks        = each.value.v4_cidr_blocks
  zone                  = each.value.zone
  network_id            = each.value.network_id
}

resource "yandex_vpc_address" "external_ip" {
  for_each = tomap({
    for external_ip in local.network_external_ips : "${external_ip.network_key}.${external_ip.external_ip_key}" => external_ip
  })
  name                  = each.value.name
  external_ipv4_address {
      zone_id           = each.value.zone_id
  }
}