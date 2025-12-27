terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # Настройка удаленного хранения стейта
  backend "gcs" {
    bucket  = "tf-state-spiral-c2-iney"  # <--- ВСТАВЬ СЮДА ИМЯ ТВОЕГО БАКЕТА!
    prefix  = "terraform/state"
    # credentials здесь не указываем, передадим через ENV или авто-поиск
  }
}

provider "google" {
  project     = "dvps-spiral-c2" # <--- ВСТАВЬ СВОЙ PROJECT ID (не имя!)
  region      = "asia-southeast1"
}