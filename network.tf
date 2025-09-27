terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.51.0"
    }
  }
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}


locals {
  # Private IP of the Cloud SQL instance (first/only entry)
  sql_private_ip = [
    for ip in google_sql_database_instance.sql_primary.ip_address :
    ip.ip_address if ip.type == "PRIVATE"
  ]
}

# Data sources used across multiple resources
data "google_storage_project_service_account" "gcs_account" {}

############################################
# NETWORKING (VPC, SUBNETS, ROUTES, FIREWALL)
############################################

# VPC network (custom mode; no default routes)
resource "google_compute_network" "vpc_main" {
  name                            = var.vpc_name
  auto_create_subnetworks         = false
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = true
}

# Subnet for webapp tier
resource "google_compute_subnetwork" "subnet_webapp" {
  name                     = var.webapp_subnet_name
  ip_cidr_range            = var.webapp_subnet_cidr
  network                  = google_compute_network.vpc_main.self_link
  region                   = var.region
  private_ip_google_access = true
}

# Subnet for database / private services
resource "google_compute_subnetwork" "subnet_db" {
  name                     = var.database_subnet_name
  ip_cidr_range            = var.database_subnet_cidr
  network                  = google_compute_network.vpc_main.self_link
  region                   = var.region
  private_ip_google_access = true
}

# Internet route for instances tagged with the webapp tag
resource "google_compute_route" "route_webapp_internet" {
  name             = var.internet_route_name
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.vpc_main.name
  next_hop_gateway = "default-internet-gateway"
  tags             = [var.webapp_subnet_name]
}

# Allowlist for app ports (HTTPS/source ranges scoped)
resource "google_compute_firewall" "fw_allow_app" {
  name    = "fw-allow-app"
  network = google_compute_network.vpc_main.self_link

  allow {
    protocol = "tcp"
    ports    = var.firewall_allow_ports
  }

  source_ranges = var.source_ranges_https
  target_tags   = [var.webapp_subnet_name, var.database_subnet_name]
}

# Deny rule for restricted ports (e.g., SSH) from broader ranges
resource "google_compute_firewall" "fw_deny_restricted" {
  name    = "fw-deny-restricted"
  network = google_compute_network.vpc_main.name

  deny {
    protocol = "tcp"
    ports    = var.firewall_deny_ports
  }

  source_ranges = var.source_ranges
  target_tags   = [var.webapp_subnet_name, var.database_subnet_name]
}

############################################
# KMS (KEY RING & KEYS) — used by SQL, GCS, VM disks
############################################

resource "google_kms_key_ring" "key_ring" {
  name     = var.kms_key_ring_name
  location = var.region
}

resource "google_kms_crypto_key" "crypto_sign_key_bucket_object" {
  name     = var.kms_bucket_objects_key_name
  key_ring = google_kms_key_ring.key_ring.id
  purpose  = var.kms_key_purpose

  version_template { algorithm = var.kms_key_algorithm }
  lifecycle { prevent_destroy = false }
  rotation_period = var.kms_key_rotation_period
}

resource "google_kms_crypto_key" "crypto_sign_key_vm" {
  name     = var.kms_vm_disks_key_name
  key_ring = google_kms_key_ring.key_ring.id
  purpose  = var.kms_key_purpose

  version_template { algorithm = var.kms_key_algorithm }
  lifecycle { prevent_destroy = false }
  rotation_period = var.kms_key_rotation_period
}

resource "google_kms_crypto_key" "crypto_sign_key_bucket" {
  name     = var.kms_storage_buckets_key_name
  key_ring = google_kms_key_ring.key_ring.id
  purpose  = var.kms_key_purpose

  version_template { algorithm = var.kms_key_algorithm }
  lifecycle { prevent_destroy = false }
  rotation_period = var.kms_key_rotation_period
}

resource "google_kms_crypto_key" "crypto_sign_key_sql" {
  name     = var.kms_cloudsql_key_name
  key_ring = google_kms_key_ring.key_ring.id
  purpose  = var.kms_key_purpose

  version_template { algorithm = var.kms_key_algorithm }
  lifecycle { prevent_destroy = false }
  rotation_period = var.kms_key_rotation_period
}

############################################
# SERVICE ACCOUNTS & IAM (for ops agent & Pub/Sub)
############################################

# Monitoring/logging service account (for VMs)
resource "google_service_account" "ops_agent_sa" {
  account_id   = var.monitoring_service_account_id
  display_name = var.monitoring_service_account_display_name
  description  = var.monitoring_service_account_description
}

# Project IAM bindings for monitoring service account
resource "google_project_iam_binding" "logging_admin" {
  project    = var.project_id
  role       = var.iam_logging_admin_role
  depends_on = [google_service_account.ops_agent_sa]

  members = ["serviceAccount:${google_service_account.ops_agent_sa.email}"]
}

resource "google_project_iam_binding" "monitoring_metric_writer" {
  project    = var.project_id
  role       = var.iam_monitoring_role
  depends_on = [google_service_account.ops_agent_sa]

  members = ["serviceAccount:${google_service_account.ops_agent_sa.email}"]
}

# Cloud Function SA is also added as publisher
resource "google_project_iam_binding" "ops_agent_publisher" {
  project    = var.project_id
  role       = var.iam_publishing_message
  depends_on = [google_service_account.ops_agent_sa, google_service_account.pubsub_sa]

  members = [
    "serviceAccount:${google_service_account.ops_agent_sa.email}",
    "serviceAccount:${google_service_account.pubsub_sa.email}"
  ]
}

############################################
# PRIVATE SERVICE CONNECT / PEERING FOR CLOUD SQL
############################################

# Allocate RFC1918 range for Service Networking (Cloud SQL private IP)
resource "google_compute_global_address" "svcnet_reserved_range" {
  name          = var.private_service_networking_address_name
  purpose       = var.private_service_networking_purpose
  address_type  = var.private_service_networking_address_type
  prefix_length = var.private_service_networking_prefix_length
  network       = google_compute_network.vpc_main.self_link
}

# Establish private VPC connection for Google managed services
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc_main.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.svcnet_reserved_range.name]
}

############################################
# SECRET MANAGER (SQL creds, host, vm key ref)
############################################

resource "google_secret_manager_secret" "secret_sql_password" {
  secret_id = var.database_password_secret_name
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "secret_sql_password_v" {
  secret      = google_secret_manager_secret.secret_sql_password.name
  secret_data = random_password.db_password.result
}

resource "google_secret_manager_secret" "secret_sql_host" {
  secret_id = var.database_host_secret_name
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "secret_sql_host_v" {
  secret      = google_secret_manager_secret.secret_sql_host.name
  secret_data = local.sql_private_ip[0]
}

resource "google_secret_manager_secret" "secret_sql_database" {
  secret_id = var.database_name_secret_name
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "secret_sql_database_v" {
  secret      = google_secret_manager_secret.secret_sql_database.name
  secret_data = var.database_name
}

resource "google_secret_manager_secret" "secret_sql_user" {
  secret_id = var.database_user_secret_name
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "secret_sql_user_v" {
  secret      = google_secret_manager_secret.secret_sql_user.name
  secret_data = var.database_user_name
}

resource "google_secret_manager_secret" "secret_vm_kms" {
  secret_id = var.vm_kms_key_secret_name
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "secret_vm_kms_v" {
  secret      = google_secret_manager_secret.secret_vm_kms.name
  secret_data = google_kms_crypto_key.crypto_sign_key_vm.id
}

# Grant Secret Manager roles to packer (or build) SA
resource "google_project_iam_binding" "secrets_access" {
  project = var.project_id
  role    = var.secret_manager_role
  depends_on = [
    google_secret_manager_secret.secret_sql_password,
    google_secret_manager_secret.secret_sql_host,
    google_secret_manager_secret.secret_vm_kms,
    google_secret_manager_secret.secret_sql_database,
    google_secret_manager_secret.secret_sql_user
  ]

  members = ["serviceAccount:${var.packer_service_account}"]
}

resource "google_project_iam_binding" "secrets_health_check" {
  project = var.project_id
  role    = var.secret_manager_health_check_role

  members = ["serviceAccount:${var.packer_service_account}"]
}

############################################
# CLOUD SQL (PRIVATE IP) + DB + USER  — PostgreSQL
############################################

# Project service identity for Cloud SQL to use CMEK
resource "google_project_service_identity" "cloud_sql_sa" {
  project = var.project_id
  service = var.cloudsql_api_service_name
}

# Allow Cloud SQL SA to use the SQL CMEK
resource "google_kms_crypto_key_iam_binding" "cmek_sql_bind" {
  crypto_key_id = google_kms_crypto_key.crypto_sign_key_sql.id
  role          = var.encrypter_decrypter_role_name
  members       = ["serviceAccount:${google_project_service_identity.cloud_sql_sa.email}"]
}

# Primary Cloud SQL instance (PostgreSQL)
resource "google_sql_database_instance" "sql_primary" {
  name                = var.database_instance_name
  database_version    = var.database_engine_version
  region              = var.database_instance_region
  depends_on          = [google_service_networking_connection.private_vpc_connection]
  deletion_protection = var.database_deletion_protection
  encryption_key_name = google_kms_crypto_key.crypto_sign_key_sql.id

  settings {
    tier                        = var.database_instance_tier
    deletion_protection_enabled = var.database_settings_deletion_protection

    # Standard backup configuration for PostgreSQL
    backup_configuration {
      enabled                        = true
      start_time                     = var.database_backup_start_time
      point_in_time_recovery_enabled = var.database_point_in_time_recovery_enabled
      backup_retention_settings {
        retained_backups = var.database_backup_retained_count
        retention_unit   = var.database_backup_retention_unit
      }
      transaction_log_retention_days = var.database_transaction_log_retention_days
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_service_networking_connection.private_vpc_connection.network
    }

    disk_autoresize   = var.database_disk_autoresize_enabled
    disk_size         = var.database_disk_size_gb
    disk_type         = var.database_disk_type
    availability_type = var.database_availability_type
  }
}

# App database
resource "google_sql_database" "webapp_sql" {
  name     = var.database_name
  instance = google_sql_database_instance.sql_primary.name
}

# DB user and password
resource "random_password" "db_password" {
  length  = var.database_password_length
  special = false
}

resource "google_sql_user" "webapp_user" {
  name     = var.database_user_name
  instance = google_sql_database_instance.sql_primary.name
  password = random_password.db_password.result
}

############################################
# GCS (FUNCTION ARTIFACTS) + KMS GRANTS
############################################

resource "google_kms_crypto_key_iam_binding" "cmek_bucket_bind" {
  crypto_key_id = google_kms_crypto_key.crypto_sign_key_bucket.id
  role          = var.encrypter_decrypter_role_name
  members       = ["serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"]
}

resource "google_kms_crypto_key_iam_binding" "cmek_bucket_obj_bind" {
  crypto_key_id = google_kms_crypto_key.crypto_sign_key_bucket_object.id
  role          = var.encrypter_decrypter_role_name
  members       = ["serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"]
}

resource "google_kms_crypto_key_iam_binding" "cmek_vm_bind" {
  crypto_key_id = google_kms_crypto_key.crypto_sign_key_vm.id
  role          = var.encrypter_decrypter_role_name
  members       = ["serviceAccount:${var.default_service_account}"]
}

resource "google_storage_bucket" "function_bucket" {
  name                        = var.cloud_function_artifacts_bucket_name
  location                    = var.region
  storage_class               = "STANDARD"
  force_destroy               = true
  uniform_bucket_level_access = true

  encryption {
    default_kms_key_name = google_kms_crypto_key.crypto_sign_key_bucket.id
  }

  depends_on = [google_kms_crypto_key_iam_binding.cmek_bucket_bind]
}

resource "google_storage_bucket_object" "function_artifact" {
  name         = var.cloud_function_source_archive_name
  bucket       = google_storage_bucket.function_bucket.name
  source       = "./cloud_function.zip"
  kms_key_name = google_kms_crypto_key.crypto_sign_key_bucket_object.id
}

############################################
# PUB/SUB (TOPIC + SA + BINDINGS + SUBSCRIPTION)
############################################

resource "google_pubsub_topic" "verify_email" {
  name                       = var.email_verification_topic_name
  message_retention_duration = var.email_verification_topic_message_retention
}

resource "google_service_account" "pubsub_sa" {
  account_id   = var.cloud_function_service_account_id
  display_name = var.cloud_function_service_account_display_name
  depends_on   = [google_pubsub_topic.verify_email]
}

resource "google_project_iam_binding" "pubsub_invoker_bind" {
  project    = var.project_id
  role       = var.pubsub_invoker_role
  depends_on = [google_service_account.pubsub_sa]

  members = ["serviceAccount:${google_service_account.pubsub_sa.email}"]
}

resource "google_pubsub_subscription" "verify_email_pull" {
  name                       = var.email_verification_subscription_name
  topic                      = google_pubsub_topic.verify_email.id
  message_retention_duration = var.message_retention_duration
  retain_acked_messages      = var.retain_acked_messages
  ack_deadline_seconds       = var.ack_deadline_seconds

  retry_policy {
    minimum_backoff = var.minimum_backoff
    maximum_backoff = var.maximum_backoff
  }

  enable_exactly_once_delivery = var.enable_exactly_once_delivery
  enable_message_ordering      = var.enable_message_ordering
}

############################################
# SERVERLESS VPC CONNECTOR (FOR CF TO SQL PRIVATE IP)
############################################

resource "google_vpc_access_connector" "cf_vpc_connector" {
  name          = var.serverless_vpc_connector_name
  region        = var.serverless_vpc_connector_region
  ip_cidr_range = var.serverless_vpc_connector_cidr
  network       = var.vpc_name
  machine_type  = var.serverless_vpc_connector_machine_type
  depends_on    = [google_compute_network.vpc_main]
}

############################################
# CLOUD FUNCTION (TRIGGERED BY PUB/SUB)
############################################

resource "google_cloudfunctions2_function" "verify_email" {
  name        = var.email_verification_function_name
  location    = var.email_verification_function_region
  description = var.email_verification_function_description

  build_config {
    runtime     = var.email_verification_function_runtime
    entry_point = var.email_verification_function_entry_point

    source {
      storage_source {
        bucket = google_storage_bucket.function_bucket.name
        object = google_storage_bucket_object.function_artifact.name
      }
    }
  }

  service_config {
    available_memory      = var.email_verification_function_memory
    timeout_seconds       = var.email_verification_function_timeout
    service_account_email = google_service_account.pubsub_sa.email
    ingress_settings      = "ALLOW_INTERNAL_ONLY"
    vpc_connector         = google_vpc_access_connector.cf_vpc_connector.self_link

    environment_variables = {
      MAILGUN_API_KEY     = var.MAILGUN_API_KEY
      WEBAPP_URL          = var.WEBAPP_URL
      SQL_HOSTNAME        = local.sql_private_ip[0]
      SQL_PASSWORD        = random_password.db_password.result
      SQL_DATABASENAME    = google_sql_database.webapp_sql.name
      SQL_USERNAME        = google_sql_user.webapp_user.name
      MAILGUN_USERNAME    = var.mailgun_username
      PUBSUB_TOPIC_NAME   = var.email_verification_topic_name
      WEBAPP_DOMAIN_NAME  = var.webapp_domain_name
      METADATA_TABLE_NAME = var.metadata_table_name
      MESSAGE_FROM        = var.message_from
    }
  }

  event_trigger {
    event_type            = var.event_trigger_event_type
    pubsub_topic          = google_pubsub_topic.verify_email.id
    retry_policy          = var.event_trigger_retry_policy
    trigger_region        = var.event_trigger_region
    service_account_email = google_service_account.pubsub_sa.email
  }

  depends_on = [
    google_pubsub_topic.verify_email,
    google_service_account.pubsub_sa,
    google_storage_bucket.function_bucket,
    google_storage_bucket_object.function_artifact
  ]
}

############################################
# COMPUTE: TEMPLATE → MIG → AUTOSCALER → HEALTH CHECK
############################################

resource "google_compute_health_check" "hc_http" {
  name                = var.webapp_health_check_name
  check_interval_sec  = var.webapp_health_check_interval_sec
  timeout_sec         = var.webapp_health_check_timeout_sec
  healthy_threshold   = var.webapp_health_check_healthy_threshold
  unhealthy_threshold = var.webapp_health_check_unhealthy_threshold

  http_health_check {
    port         = 8080
    request_path = "/healthz"
  }
}

resource "google_compute_region_instance_template" "webapp_template" {
  name         = var.webapp_instance_template_name
  machine_type = var.webapp_instance_machine_type
  region       = var.region
  tags         = [var.webapp_subnet_name]

  depends_on = [
    google_service_account.ops_agent_sa,
    google_project_iam_binding.logging_admin,
    google_project_iam_binding.monitoring_metric_writer,
    google_project_iam_binding.ops_agent_publisher
  ]

  disk {
    source_image = var.webapp_instance_source_image
    auto_delete  = false
    boot         = true
    disk_size_gb = var.webapp_instance_boot_disk_size_gb
    disk_type    = var.webapp_instance_boot_disk_type

    disk_encryption_key {
      kms_key_self_link = google_kms_crypto_key.crypto_sign_key_vm.id
    }
  }

  network_interface {
    network    = google_compute_network.vpc_main.self_link
    subnetwork = google_compute_subnetwork.subnet_webapp.self_link
    access_config {}
  }

  service_account {
    email  = google_service_account.ops_agent_sa.email
    scopes = var.service_account_scopes
  }

  metadata_startup_script = templatefile("${path.module}/startup.sh", {
    sql_hostname     = local.sql_private_ip[0]
    sql_password     = random_password.db_password.result
    sql_databasename = google_sql_database.webapp_sql.name
    sql_username     = google_sql_user.webapp_user.name
    sql_port         = var.database_port
    salt_rounds      = var.salt_rounds
  })
}

resource "google_compute_region_instance_group_manager" "webapp_mig" {
  name               = var.webapp_instance_group_name
  base_instance_name = "instance"
  region             = var.region

  version {
    instance_template = google_compute_region_instance_template.webapp_template.id
  }

  named_port {
    name = var.webapp_instance_group_port_name
    port = 8080
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.hc_http.id
    initial_delay_sec = 300
  }

  update_policy {
    type                  = var.webapp_mig_update_policy_type
    minimal_action        = var.webapp_mig_update_minimal_action
    max_surge_fixed       = var.webapp_mig_max_surge_instances
    max_unavailable_fixed = var.webapp_mig_max_unavailable_instances
    replacement_method    = var.webapp_mig_replacement_method
  }
}

resource "google_compute_region_autoscaler" "webapp_autoscaler" {
  name   = var.webapp_autoscaler_name
  target = google_compute_region_instance_group_manager.webapp_mig.id
  region = var.region

  autoscaling_policy {
    max_replicas    = var.webapp_autoscaler_max_replicas
    min_replicas    = var.webapp_autoscaler_min_replicas
    cooldown_period = var.webapp_autoscaler_cooldown_period

    cpu_utilization { target = var.webapp_autoscaler_cpu_target }
  }

  depends_on = [google_compute_region_instance_group_manager.webapp_mig]
}

############################################
# L7 HTTPS LOAD BALANCING + DNS
############################################

resource "google_compute_backend_service" "backend_service" {
  name                  = var.webapp_backend_service_name
  port_name             = var.webapp_instance_group_port_name
  protocol              = var.webapp_backend_protocol
  health_checks         = [google_compute_health_check.hc_http.id]
  load_balancing_scheme = var.webapp_load_balancer_scheme

  backend {
    group = google_compute_region_instance_group_manager.webapp_mig.instance_group
  }
}

resource "google_compute_url_map" "url_map" {
  name            = var.webapp_url_map_name
  default_service = google_compute_backend_service.backend_service.id
}

resource "google_compute_managed_ssl_certificate" "ssl_cert" {
  name = "ssl-certificate"

  managed {
    domains = [var.webapp_ssl_certificate_domain]
  }
}

resource "google_compute_target_https_proxy" "https_proxy" {
  name             = var.webapp_https_proxy_name
  url_map          = google_compute_url_map.url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_cert.id]
}

resource "google_compute_global_forwarding_rule" "fr_https" {
  name       = var.webapp_forwarding_rule_name
  target     = google_compute_target_https_proxy.https_proxy.id
  port_range = "443"
}

resource "google_dns_record_set" "a_record" {
  name         = var.webapp_dns_record_name
  type         = "A"
  ttl          = var.webapp_dns_record_ttl
  managed_zone = var.webapp_managed_dns_zone_name
  rrdatas      = [google_compute_global_forwarding_rule.fr_https.ip_address]
  depends_on   = [google_compute_global_forwarding_rule.fr_https]
}
