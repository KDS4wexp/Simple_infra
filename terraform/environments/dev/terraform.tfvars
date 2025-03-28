networks = {
  
  "network_1" = {
    name = "network_1"

    subnets = {
      "public_1" = {
        name            = "public_1" 
        v4_cidr_blocks  = ["172.16.17.0/28"]
        zone            = "ru-central1-a"
      }

      "private_1" = {
        name            = "private_1" 
        v4_cidr_blocks  = ["172.16.16.0/24"]
        zone            = "ru-central1-a"
      }
    }

    external_ips = {
      "external_ip_1" = {
        name            = "bastion-external-ip_1"
        zone_id         = "ru-central1-a" 
      }
    }
  }
}