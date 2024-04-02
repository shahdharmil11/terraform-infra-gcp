packer {
  required_plugins {
    googlecompute = {
      version = ">= 1.1.4"
      source  = "github.com/hashicorp/googlecompute"
    }
  }
}

source "googlecompute" "my-image" {
  project_id        = "cloud-project-04"
  source_image      = "centos-stream-8-v20240110"
  credentials_file  = "cloud-project-04-592b0a6c5422.json"
  ssh_username      = "packer"
  image_name        = "image-with-changed-logs-03"
  image_description = "Custom image with Java, Maven, PostgreSQL, and web application"
  zone              = "us-east1-c"
  disk_size         = 20
  machine_type      = "n1-standard-1"
  network           = "default"
}

build {
  sources = ["source.googlecompute.my-image"]

  provisioner "file" {
    source      = "webapp.zip"
    destination = "~/webapp.zip"
  }

  provisioner "file" {
    source      = "env_vars.sh"
    destination = "~/env_vars.sh"
  }

  provisioner "file" {
    source      = "setup_cloud_instance.sh"
    destination = "~/setup_cloud_instance.sh"
  }

  provisioner "shell" {
    inline = [
    "sudo bash ~/env_vars.sh"]
  }

  provisioner "shell" {
    inline = [
      "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk",
      "export PATH=$JAVA_HOME/bin:$PATH",
      "source ~/env_vars.sh",
    "sudo bash ~/setup_cloud_instance.sh"]
  }

  provisioner "shell" {
    inline = [
      "curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh",
      "sudo bash add-google-cloud-ops-agent-repo.sh --also-install",
      "sudo systemctl enable google-cloud-ops-agent",
      "sudo systemctl start google-cloud-ops-agent"
    ]
  }

  provisioner "shell" {
    script = "./agent.sh"
  }

}