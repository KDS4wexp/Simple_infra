data "terraform_remote_state" "backend" {
  backend = "s3"

  config = {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    region = "ru-central1"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    skip_metadata_api_check     = true
  }
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
