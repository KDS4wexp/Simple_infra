resource "yandex_vpc_network" "network" {                                                   # Создаем сеть network
  name = "network"
}
resource "yandex_vpc_subnet" "public_a" {                                                   # Создаем подсеть в network с зоной a и cidr 10.0.0.0/24
  name = "public_a"
  v4_cidr_blocks = ["10.0.0.0/24"]
  zone = "ru-central1-a"
  network_id = yandex_vpc_network.network.id
}
resource "yandex_vpc_subnet" "private_a" {                                                  # Создаем подсеть в network с зоной a и cidr 10.0.1.0/24
  name = "private_a"
  v4_cidr_blocks = ["10.0.1.0/24"]
  zone = "ru-central1-a"
  network_id = yandex_vpc_network.network.id
  route_table_id = yandex_vpc_route_table.route.id
}
resource "yandex_vpc_address" "bastion_ip" {                                                # Выделяем для bastion host белый ip
  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}
resource "yandex_vpc_route_table" "route" {                                                 # Создаем таблицу маршрутизации, которая предоставляет нодам доступ к внешней сети
  name = "route"
  network_id = yandex_vpc_network.network.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id = yandex_vpc_gateway.gateway.id
  }
}
resource "yandex_vpc_gateway" "gateway" {                                                   # Создаем шлюз для выхода во внешнюю сеть
  name = "gateway"
  shared_egress_gateway {}
}
resource "yandex_dns_zone" "public_zone" {                                                  # Создаем публичную днс зону
  name = "public"
  zone = "kds4wexp.ru."
  public = true
}
resource "yandex_dns_zone" "private_zone" {                                                 # Создаем приватную днс зону и подключаем к network
  name = "private"
  zone = "private."
  private_networks = [yandex_vpc_network.network.id]
}
resource "yandex_cm_certificate" "cert" {                                                   # Создаем сертификат, для этого нужно сделать CNAME запись в днс
  name = "cert"
  domains = ["kds4wexp.ru"]
  managed {
    challenge_type = "DNS_CNAME"
  }
}
resource "yandex_dns_recordset" "cert" {                                                    # Добавляем в публичную зону DNS запись CNAME для сертификата
  zone_id = yandex_dns_zone.public_zone.id
  name = yandex_cm_certificate.cert.challenges.0.dns_name
  type = yandex_cm_certificate.cert.challenges.0.dns_type
  ttl = 200
  data = [yandex_cm_certificate.cert.challenges.0.dns_value]
}
resource "yandex_dns_recordset" "rs_bastion" {                                              # Добавляем запись для bastion
  name = "bastion"
  zone_id = yandex_dns_zone.public_zone.id
  type = "A"
  ttl = 200
  data = [yandex_compute_instance.bastion.network_interface.0.nat_ip_address]
}
resource "yandex_dns_recordset" "rs_bastion_gitlab" {                                       # Добавляем запись для bastion чтобы перенаправлять запросы на gitlab
  name = "gitlab"
  zone_id = yandex_dns_zone.public_zone.id
  type = "A"
  ttl = 200
  data = [yandex_compute_instance.bastion.network_interface.0.nat_ip_address]
}
resource "yandex_dns_recordset" "rs_m_node" {                                               # Добавляем запись для master-node 
  name = "m-node"
  zone_id = yandex_dns_zone.private_zone.id
  type = "A"
  ttl = 200
  data = [yandex_compute_instance.m_node.network_interface.0.ip_address]
}
resource "yandex_dns_recordset" "rs_w_node_0" {                                             # Добавляем запись для worker-node-0 
  name = "w-node-0"
  zone_id = yandex_dns_zone.private_zone.id
  type = "A"
  ttl = 200
  data = [yandex_compute_instance.w_node_0.network_interface.0.ip_address]
}
resource "yandex_dns_recordset" "rs_w_node_1" {                                             # Добавляем запись для worker-node-1 
  name = "w-node-1"
  zone_id = yandex_dns_zone.private_zone.id
  type = "A"
  ttl = 200
  data = [yandex_compute_instance.w_node_1.network_interface.0.ip_address]
}
resource "yandex_dns_recordset" "rs_gitlab" {                                               # Добавляем запись для gitlab  
  name = "gitlab"
  zone_id = yandex_dns_zone.private_zone.id
  type = "A"
  ttl = 200
  data = [yandex_compute_instance.gitlab.network_interface.0.ip_address]
}
# resource "yandex_vpc_security_group" "bastion_security"{                                  # Создаем группу безопасности для сети network
#   name = "bastion_security"                                                               # разрешаем входящий трафик только по 22, 80, 443 портам 
#   network_id = yandex_vpc_network.network.id                                              # исходящий трафик разрешен на любом порту
#   ingress {
#     description = "ANY"
#     protocol = "ANY"
#     predefined_target = "self_security_group"
#   }
#   ingress {
#     description = "SSH"
#     protocol = "TCP"
#     port = "22"
#     predefined_target = "self_security_group"
#   }
#   ingress {
#     description = "HTTP"
#     protocol = "TCP"
#     port = "80"
#     predefined_target = "self_security_group"
#   }
#   ingress {
#     description = "HTTPS"
#     protocol = "TCP"
#     port = "443"
#     predefined_target = "self_security_group"
#   }
#   egress {
#     description = "ANY"
#     protocol = "ANY"
#     predefined_target = "self_security_group"
#   }
# }
resource "yandex_compute_instance" "bastion" {                                            # Создаем bastion host для подключения к внутренней инфре извне
  name = "bastion"                                                                        # необходимо предварительно сгенерировать пару rsa ключей в домашней дериктории
  zone = "ru-central1-a"                                                                  # образ машины - debian 12
  hostname = "bastion"                                                                  
  resources {                                                                                                                         
    cores = 2                                                                   
    memory = 2                                                                  
  }
  boot_disk {
    initialize_params {
      image_id = "fd8vcepv1aqfhv50oqjf"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.public_a.id
    nat = true
    nat_ip_address = yandex_vpc_address.bastion_ip.external_ipv4_address.0.address
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private_a.id
    # security_group_ids = [yandex_vpc_security_group.bastion_security.id]
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
resource "yandex_compute_instance" "m_node" {                                             # Создаем master-node
  name = "m-node"                                                                         # необходимо предварительно сгенерировать пару rsa ключей в домашней дериктории
  zone = "ru-central1-a"                                                                  # образ машины - debian 12
  hostname = "m-node"                                                                  
  resources {                                                                                                                        
    cores = 2                                                                   
    memory = 2                                                                  
  }
  boot_disk {
    initialize_params {
      image_id = "fd8vcepv1aqfhv50oqjf"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private_a.id
    # security_group_ids = [yandex_vpc_security_group.bastion_security.id]
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
resource "yandex_compute_instance" "w_node_0" {                                             # Создаем worker-node-0
  name = "w-node-0"                                                                         # необходимо предварительно сгенерировать пару rsa ключей в домашней дериктории
  zone = "ru-central1-a"                                                                    # образ машины - debian 12
  hostname = "w-node-0"                                                                    
  resources {                                                                                                                        
    cores = 2                                                                   
    memory = 2                                                                  
  }
  boot_disk {
    initialize_params {
      image_id = "fd8vcepv1aqfhv50oqjf"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private_a.id
    # security_group_ids = [yandex_vpc_security_group.bastion_security.id]
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
resource "yandex_compute_instance" "w_node_1" {                                             # Создаем worker-node-1
  name = "w-node-1"                                                                         # необходимо предварительно сгенерировать пару rsa ключей в домашней дериктории
  zone = "ru-central1-a"                                                                    # образ машины - debian 12
  hostname = "w-node-1"                                                                    
  resources {                                                                                                                        
    cores = 2                                                                   
    memory = 2                                                                  
  }
  boot_disk {
    initialize_params {
      image_id = "fd8vcepv1aqfhv50oqjf"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private_a.id
    # security_group_ids = [yandex_vpc_security_group.bastion_security.id]
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
resource "yandex_compute_instance" "gitlab" {                                               # Создаем gitlab host
  name = "gitlab"                                                                           # необходимо предварительно сгенерировать пару rsa ключей в домашней дериктории
  zone = "ru-central1-a"                                                                    # образ машины - debian 12
  hostname = "gitlab"                                                                     
  resources {                                                                                                                        
    cores = 4                                                                   
    memory = 8                                                                  
  }
  boot_disk {
    initialize_params {
      image_id = "fd8vcepv1aqfhv50oqjf"
      size = 16
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.private_a.id
    # security_group_ids = [yandex_vpc_security_group.bastion_security.id]
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}