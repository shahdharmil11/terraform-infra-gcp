#variables.tf

variable "project_id" {
  description = "Project ID will be created resources here"
}

variable "region" {
  description = "The region where resources will be created"
}

variable "auto_create_subnetworks" {
  description = "Auto Create subnetworks"
}

variable "credentials_file_path" {
  description = "Path to the credentials file"
}

variable "cidr1" {}
variable "cidr2" {}

variable "route_name" {}

variable "route_dest_range" {}

variable "machine_type" {}

variable "image_size" {
  default = "100"
}

variable "image_type" {
  default = "pd-standard"
}

variable "firewall_deny" {
  default = ["22"]
}

variable "firewall_allow" {
  default = ["3000", "8080"]
}

variable "vpcname" {
}

variable "DB_USER" {}

variable "DB_NAME" {}

variable "autocreatesubnets" {
  type = bool
}

variable "routingmode" {
  default = ""
}
variable "deletedefaultroutes" {
  default = ""
}


variable "virtualmachinename" {}
variable "virtualmachinezone" {}
variable "virtualmachinetype" {}
variable "virtualmachineimage" {}
variable "virtualmachinedisktype" {}
variable "virtualmachinedisksizegb" {}

variable "vm_tag" {
  type    = list(string)
  default = ["webapp"]
}
variable "database_version" {}
variable "deletion_protection" {}
variable "database_tier" {}
variable "database_edition" {}
variable "availability_type" {}


variable "disk_type" {}
variable "disk_size" {}
variable "ipv4_enabled" {}
variable "privateipgoogleaccess" {
  type = bool
}
variable "domain_name" {}

variable "iam_publishing_message" {}
variable "pubsub_topic_name" {}
variable "pubsub_service_account_publisher_role" {}
variable "pubsub_service_account_invoker_role" {}
variable "pubsub_service_account_id" {}
variable "pubsub_service_account_display_name" {}
variable "cloud_function_name" {}
variable "cloud_function_description" {}
variable "cloud_function_runtime" {}
variable "cloud_function_entry_point" {}
variable "cloud_function_region" {}
variable "cloud_function_timeout" {}
variable "cloud_function_available_memory_mb" {}
variable "MAILGUN_API_KEY" {}
variable "pubsub_subscription_name" {}
variable "WEBAPP_URL" {}
variable "managed_zone" {}
variable "service_account_id" {}
variable "iam_logging_admin_role" {}
variable "iam_monitoring_role" {}

variable "cloudfunction_account_id" {
  description = "The account id of Cloud Function"
  type        = string
}
variable "cloudfunction_display_name" {
  description = "The display Name of Cloud Function"
  type        = string
}
variable "cloudstorage_bucketname" {
  description = "Cloud Storage Bucket Name"
  type        = string
}

variable "cloudstorage_bucketobjectname" {
  description = "Name of cloud storage bucket object"
  type        = string
}
variable "cloudstorage_source" {
  description = "Zip folder Source Name of cloud storage"
  type        = string
}

variable "cloudfunction_name" {
  description = "Name of the cloud function"
  type        = string
}
variable "cloudfunction_runtime" {
  description = "Cloud Function Runtime"
  type        = string
}
variable "cloudfunction_entry_point" {
  description = "Cloud Function Entry point"
  type        = string
}

variable "vpc_connector_egress_settings" {
  description = "Egress settings for the VPC connector"
  type        = string
}

variable "ingress_settings" {
  description = "Ingress settings for the Cloud Function"
  type        = string
}

variable "all_traffic_on_latest_revision" {
  description = "Set to true to route all traffic to the latest Cloud Function revision"
  type        = bool
}

variable "ack_deadline_seconds" {
  description = "Ack Deadline Seconds"
  type        = number
}
variable "ttl" {
  description = "Pub/Sub TTL"
  type        = string
}
