#!/bin/bash


LOG_FILE="/var/log/install_dependencies.log"
ERROR_LOG_FILE="/var/log/install_dependencies_error.log"

# Redirect stdout and stderr to log files
exec > >(tee -a "$LOG_FILE") 2> >(tee -a "$ERROR_LOG_FILE" >&2)


# Update and install necessary packages
sudo yum -y update
sudo yum install -y java-17-openjdk-devel
java -version
sudo yum install -y maven
mvn -version

export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export PATH=$JAVA_HOME/bin:$PATH
export M2_HOME=/opt/maven
export PATH=$M2_HOME/bin:$PATH


# Enable and start PostgreSQL service
#sudo systemctl enable --now postgresql
#dnf module list postgresql
#dnf module enable postgresql:16
#sudo dnf install postgresql-server
#sudo postgresql-setup --initdb

sudo apt-get install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
sudo systemctl status postgresql
sudo su - postgres -c "psql -c \"CREATE DATABASE CLOUD;\""
sudo su - postgres -c "psql -c \"ALTER USER postgres WITH PASSWORD 'admin';\""
sudo su - postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE CLOUD TO postgres;\""

# Install unzip
dnf install unzip

# Install other dependencies as needed

# Clean up
sudo yum clean all
sudo rm -rf /var/cache/yum

unzip webapp.zip

mvn clean install

# Customize the script based on your application's specific needs

# For example, if you have a Spring Boot application, you might copy the JAR file:
sudo cp /target/assingment-0.0.1-SNAPSHOT.jar /opt/app/

# Add any other configurations or installations specific to your application

# Ensure the service or application starts on instance launch (example for Tomcat)
# sudo systemctl enable --now tomcat.service

# ... add other setup or installation steps as needed