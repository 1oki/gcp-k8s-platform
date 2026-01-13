# Бакет для бэкапов БД
resource "google_storage_bucket" "backup" {
  name          = "spiral-db-backups-${var.env_name}" # Будет: spiral-db-backups-spiral-c2
  location      = var.region # Автоматически возьмет us-central1
  force_destroy = true       # Позволяет удалить бакет, даже если там есть файлы (для обучения)

  uniform_bucket_level_access = true
}

# Даем права сервисному аккаунту бэкапов (который мы создавали руками в Дне 10, но давай его тоже в код засунем!)
# ...но пока давай просто создадим бакет, чтобы не усложнять IAM в коде сейчас.