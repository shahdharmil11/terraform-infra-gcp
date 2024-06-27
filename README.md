<h1>Infra setup for web application on GCP using IaC tool Terraform</h1>

<h2>Project name:</h2>
GCP-Infrastructure

GCP Service APIs enabled:
Compute Engine API
Cloud Monitoring API
Cloud Logging API
Cloud DNS API
Service Networking API
Cloud Build API
Cloud Functions API
Cloud Pub/Sub API
Eventarc API
Cloud Run Admin API

CLI setup:
gcloud auth login
gcloud auth application-default login
gcloud config set project csye6225-eashan-roy

Terraform commands:
terraform init
terraform fmt terraform validate
terraform plan
terraform apply
terraform destroy

Infra provisioned independent of Terraform DNS zone (Note: A, SPF, DKIM, MX records are created via tf, only the zone is manually setup)

GitHub Actions workflow
CI workflow to format and validate terraform code before PR can be merged to organization repo's main branch
