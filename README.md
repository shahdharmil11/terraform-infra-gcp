# terraform-infra-gcp
Infra setup for web application on GCP using IaC tool Terraform

<img src="https://github.com/shahdharmil11/terraform-infra-gcp/blob/master/gcp-infra.jpeg"  title="Infra provisioned">

- Project name:  
GCP-Infrastructure
  
- GCP Service APIs enabled:  
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

- CLI setup:  
gcloud auth login   
gcloud auth application-default login  
gcloud config set project csye6225-webapp-cloud  

- Terraform commands:  
terraform init  
terraform fmt
terraform validate  
terraform plan  
terraform apply  
terraform destroy  

- Infra provisioned independent of Terraform
DNS zone (Note: A, SPF, DKIM, MX records are created via tf, only the zone is manually setup)

# serverless
Code for Google Cloud Function  

-- The Cloud Function will do the following:

1. Receive the base64 encoded message (containing email id of the user) from the Pub/Sub topic
2. Decode the message, deserialize it, insert a verification token in the cloudsql db associated with the email id of the user, and also add a timer of 2 minutes
3. Send mail to the user using mailgun's api that contains the verification url. When user clicks the link, it redirects them to the '/verify' endpoint of the web application   

- GitHub Actions workflow  
CI workflow to format and validate terraform code before PR can be merged to organization repo's main branch
