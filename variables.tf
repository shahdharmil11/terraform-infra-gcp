# variables.tf - Complete variable definitions for enterprise GCP infrastructure

############################################
# PROJECT & REGION CONFIGURATION
############################################

variable "project_id" {
  description = "The GCP project ID where all resources will be created"
  type        = string
}

variable "region" {
  description = "The GCP region where resources will be deployed (e.g., us-central1, us-east1)"
  type        = string
}

############################################
# NETWORKING VARIABLES
############################################

variable "vpc_name" {
  description = "Name of the VPC network to be created"
  type        = string
}

variable "routing_mode" {
  description = "Network routing mode (REGIONAL or GLOBAL)"
  type        = string
  default     = "REGIONAL"
}

variable "webapp_subnet_name" {
  description = "Name of the webapp tier subnet"
  type        = string
}

variable "webapp_subnet_cidr" {
  description = "CIDR range for the webapp subnet (e.g., 10.0.1.0/24)"
  type        = string
}

variable "database_subnet_name" {
  description = "Name of the database tier subnet"
  type        = string
}

variable "database_subnet_cidr" {
  description = "CIDR range for the database subnet (e.g., 10.0.2.0/24)"
  type        = string
}

variable "internet_route_name" {
  description = "Name of the custom route for internet access"
  type        = string
}

############################################
# FIREWALL CONFIGURATION
############################################

variable "firewall_allow_ports" {
  description = "List of ports to allow through the firewall (e.g., ['80', '443', '8080'])"
  type        = list(string)
  default     = ["80", "443", "8080"]
}

variable "firewall_deny_ports" {
  description = "List of ports to deny through the firewall (e.g., ['22', '3389'])"
  type        = list(string)
  default     = ["22"]
}

variable "source_ranges_https" {
  description = "CIDR ranges allowed for HTTPS traffic"
  type        = list(string)
}

variable "source_ranges" {
  description = "CIDR ranges for general firewall rules"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

############################################
# KMS ENCRYPTION VARIABLES
############################################

variable "kms_key_ring_name" {
  description = "Name of the KMS key ring for encryption"
  type        = string
}

variable "kms_bucket_objects_key_name" {
  description = "Name of the KMS crypto key for bucket objects"
  type        = string
}

variable "kms_vm_disks_key_name" {
  description = "Name of the KMS crypto key for VM disk encryption"
  type        = string
}

variable "kms_storage_buckets_key_name" {
  description = "Name of the KMS crypto key for bucket encryption"
  type        = string
}

variable "kms_cloudsql_key_name" {
  description = "Name of the KMS crypto key for SQL database encryption"
  type        = string
}

variable "kms_key_purpose" {
  description = "Purpose of the crypto key (ENCRYPT_DECRYPT)"
  type        = string
  default     = "ENCRYPT_DECRYPT"
}

variable "kms_key_algorithm" {
  description = "Algorithm for the crypto key"
  type        = string
  default     = "GOOGLE_SYMMETRIC_ENCRYPTION"
}

variable "kms_key_rotation_period" {
  description = "Key rotation period (e.g., '7776000s' for 90 days)"
  type        = string
  default     = "7776000s"
}

############################################
# SERVICE ACCOUNT VARIABLES
############################################

variable "monitoring_service_account_id" {
  description = "Account ID for the monitoring and logging service account"
  type        = string
}

variable "monitoring_service_account_display_name" {
  description = "Display name for the monitoring and logging service account"
  type        = string
}

variable "monitoring_service_account_description" {
  description = "Description for the monitoring and logging service account"
  type        = string
}

variable "cloud_function_service_account_id" {
  description = "Account ID for the Cloud Function service account"
  type        = string
}

variable "cloud_function_service_account_display_name" {
  description = "Display name for the Cloud Function service account"
  type        = string
}

variable "packer_service_account" {
  description = "Email of the packer/build service account for secret access"
  type        = string
}

variable "default_service_account" {
  description = "Default service account for VM KMS binding"
  type        = string
}

############################################
# IAM ROLE VARIABLES
############################################

variable "iam_logging_admin_role" {
  description = "IAM role for logging admin access"
  type        = string
  default     = "roles/logging.admin"
}

variable "iam_monitoring_role" {
  description = "IAM role for monitoring metric writer"
  type        = string
  default     = "roles/monitoring.metricWriter"
}

variable "iam_publishing_message" {
  description = "IAM role for Pub/Sub message publishing"
  type        = string
  default     = "roles/pubsub.publisher"
}

variable "pubsub_invoker_role" {
  description = "IAM role for Pub/Sub function invoker"
  type        = string
  default     = "roles/cloudfunctions.invoker"
}

variable "secret_manager_role" {
  description = "IAM role for Secret Manager access"
  type        = string
  default     = "roles/secretmanager.secretAccessor"
}

variable "secret_manager_health_check_role" {
  description = "IAM role for Secret Manager health check access"
  type        = string
  default     = "roles/secretmanager.viewer"
}

variable "encrypter_decrypter_role_name" {
  description = "IAM role for KMS encryption/decryption"
  type        = string
  default     = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
}

############################################
# PRIVATE SERVICE NETWORKING
############################################

variable "private_service_networking_address_name" {
  description = "Name of the global address for private service networking"
  type        = string
}

variable "private_service_networking_purpose" {
  description = "Purpose of the global address (VPC_PEERING)"
  type        = string
  default     = "VPC_PEERING"
}

variable "private_service_networking_address_type" {
  description = "Address type for global address (INTERNAL)"
  type        = string
  default     = "INTERNAL"
}

variable "private_service_networking_prefix_length" {
  description = "Prefix length for the global address range"
  type        = number
  default     = 16
}

############################################
# SECRET MANAGER VARIABLES
############################################

variable "database_password_secret_name" {
  description = "Name of the secret for database password"
  type        = string
}

variable "database_host_secret_name" {
  description = "Name of the secret for database host"
  type        = string
}

variable "database_name_secret_name" {
  description = "Name of the secret for database name"
  type        = string
}

variable "database_user_secret_name" {
  description = "Name of the secret for database username"
  type        = string
}

variable "vm_kms_key_secret_name" {
  description = "Name of the secret for VM KMS key reference"
  type        = string
}

############################################
# CLOUD SQL VARIABLES
############################################

variable "cloudsql_api_service_name" {
  description = "Google API service for Cloud SQL service identity"
  type        = string
  default     = "sqladmin.googleapis.com"
}

variable "database_engine_version" {
  description = "Version of the database engine (e.g., POSTGRES_15)"
  type        = string
  default     = "POSTGRES_15"
}

variable "database_instance_name" {
  description = "Name of the Cloud SQL database instance"
  type        = string
}

variable "database_instance_region" {
  description = "Region for the Cloud SQL instance"
  type        = string
}

variable "database_deletion_protection" {
  description = "Enable deletion protection for database instance"
  type        = bool
  default     = true
}

variable "database_instance_tier" {
  description = "Machine type for the database instance (e.g., db-f1-micro, db-n1-standard-1)"
  type        = string
}

variable "database_settings_deletion_protection" {
  description = "Enable deletion protection in database instance settings"
  type        = bool
  default     = true
}

variable "database_disk_autoresize_enabled" {
  description = "Enable automatic disk resize for the database"
  type        = bool
  default     = true
}

variable "database_disk_size_gb" {
  description = "Size of the database instance disk in GB"
  type        = number
  default     = 20
}

variable "database_disk_type" {
  description = "Disk type for database instance (PD_SSD or PD_HDD)"
  type        = string
  default     = "PD_SSD"
}

variable "database_availability_type" {
  description = "Availability type for database (ZONAL or REGIONAL)"
  type        = string
  default     = "ZONAL"
}

variable "database_backup_start_time" {
  description = "Start time for automated backups in HH:MM format (UTC)"
  type        = string
  default     = "03:00"
}

variable "database_point_in_time_recovery_enabled" {
  description = "Enable point-in-time recovery for PostgreSQL"
  type        = bool
  default     = true
}

variable "database_backup_retained_count" {
  description = "Number of database backups to retain"
  type        = number
  default     = 7
}

variable "database_backup_retention_unit" {
  description = "Database backup retention unit (COUNT)"
  type        = string
  default     = "COUNT"
}

variable "database_transaction_log_retention_days" {
  description = "Number of days to retain transaction logs for PostgreSQL"
  type        = number
  default     = 7
}

variable "database_name" {
  description = "Name of the database to create"
  type        = string
}

variable "database_user_name" {
  description = "Username for the database user"
  type        = string
}

variable "database_password_length" {
  description = "Length of the randomly generated database password"
  type        = number
  default     = 32
}

############################################
# STORAGE VARIABLES
############################################

variable "cloud_function_artifacts_bucket_name" {
  description = "Name of the Cloud Storage bucket for function artifacts"
  type        = string
}

variable "cloud_function_source_archive_name" {
  description = "Name of the function source archive in the storage bucket"
  type        = string
}

############################################
# PUB/SUB VARIABLES
############################################

variable "email_verification_topic_name" {
  description = "Name of the Pub/Sub topic for email verification"
  type        = string
}

variable "email_verification_topic_message_retention" {
  description = "Message retention duration for email verification topic"
  type        = string
  default     = "604800s"
}

variable "email_verification_subscription_name" {
  description = "Name of the Pub/Sub subscription for email verification"
  type        = string
}

variable "message_retention_duration" {
  description = "Message retention duration for subscription"
  type        = string
  default     = "604800s"
}

variable "retain_acked_messages" {
  description = "Retain acknowledged messages in subscription"
  type        = bool
  default     = false
}

variable "ack_deadline_seconds" {
  description = "Acknowledgment deadline in seconds"
  type        = number
  default     = 20
}

variable "minimum_backoff" {
  description = "Minimum backoff duration for retry policy"
  type        = string
  default     = "10s"
}

variable "maximum_backoff" {
  description = "Maximum backoff duration for retry policy"
  type        = string
  default     = "600s"
}

variable "enable_exactly_once_delivery" {
  description = "Enable exactly once delivery for subscription"
  type        = bool
  default     = true
}

variable "enable_message_ordering" {
  description = "Enable message ordering for subscription"
  type        = bool
  default     = false
}

############################################
# VPC CONNECTOR VARIABLES
############################################

variable "serverless_vpc_connector_name" {
  description = "Name of the serverless VPC access connector"
  type        = string
}

variable "serverless_vpc_connector_region" {
  description = "Region for the serverless VPC connector"
  type        = string
}

variable "serverless_vpc_connector_cidr" {
  description = "CIDR range for the serverless VPC connector"
  type        = string
}

variable "serverless_vpc_connector_machine_type" {
  description = "Machine type for the serverless VPC connector"
  type        = string
  default     = "e2-micro"
}

############################################
# CLOUD FUNCTION VARIABLES
############################################

variable "email_verification_function_name" {
  description = "Name of the email verification Cloud Function"
  type        = string
}

variable "email_verification_function_region" {
  description = "Region for the email verification function deployment"
  type        = string
}

variable "email_verification_function_description" {
  description = "Description of the email verification Cloud Function"
  type        = string
}

variable "email_verification_function_runtime" {
  description = "Runtime for the email verification function (e.g., java17, python311, nodejs18)"
  type        = string
}

variable "email_verification_function_entry_point" {
  description = "Entry point function name for the email verification function"
  type        = string
}

variable "email_verification_function_memory" {
  description = "Available memory for email verification function"
  type        = string
  default     = "256Mi"
}

variable "email_verification_function_timeout" {
  description = "Timeout for email verification function in seconds"
  type        = number
  default     = 60
}

variable "event_trigger_event_type" {
  description = "Event type for Cloud Function trigger"
  type        = string
  default     = "google.cloud.pubsub.topic.v1.messagePublished"
}

variable "event_trigger_retry_policy" {
  description = "Retry policy for event trigger"
  type        = string
  default     = "RETRY_POLICY_RETRY"
}

variable "event_trigger_region" {
  description = "Region for the event trigger"
  type        = string
}

############################################
# CLOUD FUNCTION ENVIRONMENT VARIABLES
############################################

variable "MAILGUN_API_KEY" {
  description = "Mailgun API key for email sending"
  type        = string
  sensitive   = true
}

variable "WEBAPP_URL" {
  description = "URL of the web application"
  type        = string
}

variable "mailgun_username" {
  description = "Mailgun username for email configuration"
  type        = string
}

variable "webapp_domain_name" {
  description = "Domain name of the web application"
  type        = string
}

variable "metadata_table_name" {
  description = "Name of the metadata table in the database"
  type        = string
}

variable "message_from" {
  description = "From address for email messages"
  type        = string
}

############################################
# COMPUTE INSTANCE VARIABLES
############################################

variable "webapp_health_check_name" {
  description = "Name of the webapp health check"
  type        = string
}

variable "webapp_health_check_interval_sec" {
  description = "How often to perform the webapp health check (in seconds)"
  type        = number
  default     = 5
}

variable "webapp_health_check_timeout_sec" {
  description = "How long to wait before claiming webapp health check failure (in seconds)"
  type        = number
  default     = 5
}

variable "webapp_health_check_healthy_threshold" {
  description = "Number of consecutive successful checks before marking webapp healthy"
  type        = number
  default     = 2
}

variable "webapp_health_check_unhealthy_threshold" {
  description = "Number of consecutive failed checks before marking webapp unhealthy"
  type        = number
  default     = 3
}

variable "webapp_instance_template_name" {
  description = "Name of the webapp instance template"
  type        = string
}

variable "webapp_instance_machine_type" {
  description = "Machine type for webapp instances (e.g., e2-medium, n1-standard-1)"
  type        = string
}

variable "webapp_instance_source_image" {
  description = "Source image for webapp instances"
  type        = string
}

variable "webapp_instance_boot_disk_size_gb" {
  description = "Boot disk size for webapp instances in GB"
  type        = number
  default     = 20
}

variable "webapp_instance_boot_disk_type" {
  description = "Boot disk type for webapp instances (pd-standard, pd-ssd)"
  type        = string
  default     = "pd-standard"
}

variable "service_account_scopes" {
  description = "Scopes for the instance service account"
  type        = list(string)
  default     = ["cloud-platform"]
}

variable "database_port" {
  description = "Port number for database connection"
  type        = string
  default     = "5432"
}

variable "salt_rounds" {
  description = "Number of salt rounds for password hashing"
  type        = string
  default     = "10"
}

############################################
# MANAGED INSTANCE GROUP VARIABLES
############################################

variable "webapp_instance_group_name" {
  description = "Name of the webapp managed instance group"
  type        = string
}

variable "webapp_instance_group_port_name" {
  description = "Name of the named port for the webapp instance group"
  type        = string
  default     = "http"
}

variable "webapp_mig_update_policy_type" {
  description = "Update policy type for webapp managed instance group"
  type        = string
  default     = "PROACTIVE"
}

variable "webapp_mig_update_minimal_action" {
  description = "Minimal action for webapp MIG update policy"
  type        = string
  default     = "REPLACE"
}

variable "webapp_mig_max_surge_instances" {
  description = "Maximum number of webapp instances to create during update"
  type        = number
  default     = 1
}

variable "webapp_mig_max_unavailable_instances" {
  description = "Maximum number of webapp instances unavailable during update"
  type        = number
  default     = 0
}

variable "webapp_mig_replacement_method" {
  description = "Method for replacing webapp instances during update"
  type        = string
  default     = "SUBSTITUTE"
}

############################################
# AUTOSCALER VARIABLES
############################################

variable "webapp_autoscaler_name" {
  description = "Name of the webapp autoscaler"
  type        = string
}

variable "webapp_autoscaler_max_replicas" {
  description = "Maximum number of webapp instances in the autoscaler"
  type        = number
  default     = 3
}

variable "webapp_autoscaler_min_replicas" {
  description = "Minimum number of webapp instances in the autoscaler"
  type        = number
  default     = 1
}

variable "webapp_autoscaler_cooldown_period" {
  description = "Cooldown period for webapp autoscaler in seconds"
  type        = number
  default     = 60
}

variable "webapp_autoscaler_cpu_target" {
  description = "Target CPU utilization for webapp autoscaling (0.0 to 1.0)"
  type        = number
  default     = 0.6
}

############################################
# LOAD BALANCER VARIABLES
############################################

variable "webapp_backend_service_name" {
  description = "Name of the webapp backend service"
  type        = string
}

variable "webapp_backend_protocol" {
  description = "Protocol for the webapp backend service (HTTP or HTTPS)"
  type        = string
  default     = "HTTP"
}

variable "webapp_load_balancer_scheme" {
  description = "Load balancing scheme for webapp (EXTERNAL or INTERNAL)"
  type        = string
  default     = "EXTERNAL"
}

variable "webapp_url_map_name" {
  description = "Name of the webapp URL map"
  type        = string
}

variable "webapp_ssl_certificate_domain" {
  description = "Domain name for webapp SSL certificate"
  type        = string
}

variable "webapp_https_proxy_name" {
  description = "Name of the webapp HTTPS proxy"
  type        = string
}

variable "webapp_forwarding_rule_name" {
  description = "Name of the webapp global forwarding rule"
  type        = string
}

############################################
# DNS VARIABLES
############################################

variable "webapp_dns_record_name" {
  description = "Full domain name for webapp DNS A record (e.g., example.com.)"
  type        = string
}

variable "webapp_dns_record_ttl" {
  description = "TTL for webapp DNS record in seconds"
  type        = number
  default     = 300
}

variable "webapp_managed_dns_zone_name" {
  description = "Name of the managed DNS zone for webapp"
  type        = string
}
