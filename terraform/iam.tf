# iam.tf

# 1. Создаем Service Account в Google Cloud
resource "google_service_account" "postgres_backup" {
  account_id   = "postgres-backup-sa"
  display_name = "Postgres Backup Service Account"
}

# 2. Даем этому аккаунту права админа на Бакет бэкапов
resource "google_storage_bucket_iam_member" "backup_admin" {
  bucket = google_storage_bucket.backup.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.postgres_backup.email}"
}

# 3. Даем ему права "просматривать" бакет (иногда нужно для list)
resource "google_storage_bucket_iam_member" "backup_viewer" {
  bucket = google_storage_bucket.backup.name
  role   = "roles/storage.legacyBucketReader"
  member = "serviceAccount:${google_service_account.postgres_backup.email}"
}

# 4. Разрешаем Кубернетесу использовать этого робота
# Мы говорим: "Сервис-аккаунт 'spiral-app-db' из неймспейса 'default' 
# может притворяться гугловым аккаунтом 'postgres-backup-sa'"

resource "google_service_account_iam_member" "workload_identity_user" {
  service_account_id = google_service_account.postgres_backup.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[default/spiral-app-db]"
}