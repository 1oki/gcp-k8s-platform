# main.tf

# Создаем VPC (Виртуальную сеть)
# Это будет наша изолированная песочница
resource "google_compute_network" "vpc_network" {
  name                    = "spiral-vpc"
  auto_create_subnetworks = false  # Важно! Мы хотим сами контролировать подсети (в Дне 2)
}