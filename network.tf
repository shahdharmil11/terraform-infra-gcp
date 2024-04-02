terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  #  credentials = file(var.credentials_file_path)
  zone = var.virtualmachinezone
}

resource "google_compute_network" "vpcnetwork" {
  name                            = var.vpcname
  auto_create_subnetworks         = var.autocreatesubnets
  routing_mode                    = var.routingmode
  delete_default_routes_on_create = var.deletedefaultroutes
}

resource "google_compute_subnetwork" "webapp" {
  name                     = "webapp"
  ip_cidr_range            = var.cidr1
  network                  = google_compute_network.vpcnetwork.self_link
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "db" {
  name                     = "db"
  ip_cidr_range            = var.cidr2
  network                  = google_compute_network.vpcnetwork.self_link
  private_ip_google_access = true
}

resource "google_compute_route" "webapp_route" {
  name             = var.route_name
  network          = google_compute_network.vpcnetwork.name
  dest_range       = var.route_dest_range
  priority         = 1000
  next_hop_gateway = "default-internet-gateway"
}

resource "google_compute_firewall" "allow_webapplication_port" {
  name    = "${var.vpcname}-allow-webapplication"
  network = google_compute_network.vpcnetwork.id
  allow {
    protocol = "tcp"
    ports    = ["8080", "22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["webapp"]
}

resource "google_compute_firewall" "allow_ssh_from_specific_range" {
  name    = "allow-ssh-from-specific-range"
  network = google_compute_network.vpcnetwork.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [var.route_dest_range]
}

resource "google_compute_instance" "vm_instance" {
  name                      = var.virtualmachinename
  zone                      = var.virtualmachinezone
  machine_type              = var.virtualmachinetype
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.virtualmachineimage
      type  = var.virtualmachinedisktype
      size  = var.virtualmachinedisksizegb
    }
  }
  service_account {
    email  = google_service_account.service_account.email
    scopes = ["cloud-platform"]
  }
  network_interface {
    network    = google_compute_network.vpcnetwork.id
    subnetwork = google_compute_subnetwork.webapp.self_link
    access_config {
    }
  }

  tags = var.vm_tag

  metadata = {
    startup-script = <<EOT
touch /opt/application.properties
echo "spring.datasource.driver-class-name=org.postgresql.Driver" >> /opt/application.properties
echo "spring.datasource.url=jdbc:postgresql://${google_sql_database_instance.instance.private_ip_address}:5432/${var.DB_NAME}" >> /opt/application.properties
echo "spring.datasource.username=${var.DB_USER}" >> /opt/application.properties
echo "spring.datasource.password=${random_password.db_user_password.result}" >> /opt/application.properties
echo "spring.jpa.properties.hibernate.show_sql=true" >> /opt/application.properties
echo "spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect" >> /opt/application.properties
echo "spring.jpa.hibernate.ddl-auto=update" >> /opt/application.properties
echo "spring.devtools.restart.enabled=false" >> /opt/application.properties
echo "spring.datasource.hikari.connectionTimeout=10000" >> /opt/application.properties
echo "spring.datasource.hikari.maximumPoolSize=10" >> /opt/application.properties
echo "spring.jpa.properties.hibernate.format_sql=true" >> /opt/application.properties
echo "spring.jpa.show-sql=true" >> /opt/application.properties
echo "pubsub.projectId=${var.project_id}" >> /opt/application.properties
echo "pubsub.topicId=${google_pubsub_topic.pub_sub_topic.name}" >> /opt/application.properties
EOT
  }
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = google_compute_network.vpcnetwork.self_link
}

resource "google_service_networking_connection" "private_services_connection" {
  network                 = google_compute_network.vpcnetwork.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

output "private_ip" {
  value = google_sql_database_instance.instance.private_ip_address
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "instance" {
  provider            = google-beta
  project             = var.project_id
  name                = "private-instance-${random_id.db_name_suffix.hex}"
  database_version    = var.database_version
  region              = var.region
  depends_on          = [google_service_networking_connection.private_services_connection]
  deletion_protection = var.deletion_protection

  settings {
    tier    = var.database_tier
    edition = var.database_edition

    availability_type = var.availability_type
    disk_type         = var.disk_type
    disk_size         = var.disk_size

    ip_configuration {
      ipv4_enabled                                  = var.ipv4_enabled
      private_network                               = google_compute_network.vpcnetwork.id
      enable_private_path_for_google_cloud_services = true
    }
  }
}

output "generated_instance_name" {
  value     = google_sql_database_instance.instance.name
  sensitive = true
}


resource "random_password" "db_user_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

output "generated_password" {
  value     = random_password.db_user_password.result
  sensitive = true
}

resource "google_sql_user" "database_user" {
  name     = var.DB_USER
  instance = google_sql_database_instance.instance.name
  password = random_password.db_user_password.result

}

resource "google_sql_database" "database" {
  name     = var.DB_NAME
  instance = google_sql_database_instance.instance.name
}

resource "google_compute_firewall" "allow_sql_access" {
  name    = "allow-sql-access"
  network = google_compute_network.vpcnetwork.self_link

  allow {
    protocol = "tcp"
    ports    = [3306, 5432]
  }

  source_tags = var.vm_tag
}

resource "google_compute_firewall" "allow_web_access_to_sql" {
  name    = "allow-web-access-to-sql"
  network = google_compute_network.vpcnetwork.self_link

  allow {
    protocol = "tcp"
    ports    = [3306, 5432]

  }
  source_tags = var.vm_tag
}

data "google_dns_managed_zone" "my_dns_zone" {
  name = var.domain_name
}

resource "google_dns_record_set" "my_dns_record" {
  name         = var.domain_name
  type         = "A"
  ttl          = 300
  managed_zone = var.managed_zone
  rrdatas      = [google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip]
}

resource "google_service_account" "service_account" {
  account_id   = var.service_account_id
  display_name = "Service Account for logging"
}

resource "google_project_iam_binding" "logging_admin" {
  project = var.project_id
  role    = "roles/logging.admin"

  members = [
    "serviceAccount:${google_service_account.service_account.email}"
  ]
}

resource "google_project_iam_binding" "monitoring_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"

  members = [
    "serviceAccount:${google_service_account.service_account.email}"
  ]
}

resource "google_pubsub_topic" "pub_sub_topic" {
  name                       = var.pubsub_topic_name
  message_retention_duration = "604800s"
  depends_on                 = [google_service_networking_connection.private_services_connection]
}

# Create a Pub/Sub subscription
resource "google_pubsub_subscription" "pub_sub_subscription" {
  name                 = var.pubsub_subscription_name
  topic                = google_pubsub_topic.pub_sub_topic.name
  ack_deadline_seconds = var.ack_deadline_seconds
  expiration_policy {
    ttl = var.ttl
  }
}

resource "google_service_account" "function_service_account" {
  account_id   = var.cloudfunction_account_id
  display_name = "Function Service Account"
}

resource "google_project_iam_binding" "function_service_account_roles" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"

  members = [
    "serviceAccount:${google_service_account.function_service_account.email}"
  ]
}

resource "google_storage_bucket" "function_code_bucket" {
  name     = var.cloudstorage_bucketname
  location = var.region
}

resource "google_storage_bucket_object" "function_code_objects" {
  name   = var.cloudstorage_bucketobjectname
  bucket = google_storage_bucket.function_code_bucket.name
  source = var.cloudstorage_source
}

resource "google_cloudfunctions2_function" "email_verification_function" {
  name     = var.cloudfunction_name
  location = var.region

  build_config {
    runtime     = var.cloudfunction_runtime
    entry_point = var.cloudfunction_entry_point

    source {
      storage_source {
        bucket = google_storage_bucket.function_code_bucket.name
        object = google_storage_bucket_object.function_code_objects.name
      }
    }
  }

  service_config {
    max_instance_count            = 1
    min_instance_count            = 1
    available_memory              = var.cloud_function_available_memory_mb
    timeout_seconds               = var.cloud_function_timeout
    vpc_connector                 = google_vpc_access_connector.connector.name
    vpc_connector_egress_settings = var.vpc_connector_egress_settings

    environment_variables = {
      SQL_PRIVATE_IP = google_sql_database_instance.instance.private_ip_address
      SQL_USERNAME   = var.DB_USER
      SQL_PASSWORD   = random_password.db_user_password.result
      DB_NAME        = var.DB_NAME
    }

    ingress_settings               = var.ingress_settings
    all_traffic_on_latest_revision = var.all_traffic_on_latest_revision
    service_account_email          = google_service_account.function_service_account.email

  }
  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.pub_sub_topic.id
  }
}

resource "google_project_iam_binding" "pubsub_publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"

  members = [
    "serviceAccount:${google_service_account.service_account.email}"
  ]
}

resource "google_project_iam_binding" "pubsub_service_account_roles" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"

  members = [
    "serviceAccount:${google_service_account.service_account.email}"
  ]
}

resource "google_vpc_access_connector" "connector" {
  name          = "serverless-vpc-connector"
  region        = var.region
  ip_cidr_range = "192.162.0.0/28"
  network       = google_compute_network.vpcnetwork.name
}
