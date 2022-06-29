output "yandex_vpc_network_net_name" {
  value = "${yandex_vpc_network.default.name}"
}

output "yandex_vpc_subnet_subnet_name" {
  value = "${yandex_vpc_subnet.default.name}"
}

output "yandex_compute_image_my_image_id" {
  value = "${yandex_compute_image.my_image.id}"
}

output "external_ip_address_node01" {
  value = "${yandex_compute_instance.node01.network_interface.0.nat_ip_address}"
}