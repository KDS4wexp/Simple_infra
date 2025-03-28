module "network" {
    source = "../../modules/network"

    networks = var.networks


    providers = {
        yandex = yandex
    }
}