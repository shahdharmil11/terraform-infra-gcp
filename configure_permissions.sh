#!/bin/bash


# Log file path
LOG_FILE="/var/log/configure_permissions.log"

# Function to log messages
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | sudo tee -a "$LOG_FILE" > /dev/null
}


log "Starting configure_permissions.sh script..."

# Create non-login user csye6225 with /usr/sbin/nologin shell
sudo useradd -m -s /usr/sbin/nologin csye6225
log "User csye6225 created."

# Check if user creation was successful
if [ $? -ne 0 ]; then
  echo "Error: Failed to create user csye6225."
  exit 1
fi

sudo chown -R csye6225:csye6225 /opt/app
sudo chmod -R 755 /opt/app

log "Ownership and permissions set for /opt/app."

# Add csye6225 to any required groups or modify permissions as needed
usermod -aG csye6225 csye6225

echo "csye6225 ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/csye6225

log "User csye6225 added to sudoers."

# Clean up and customize as needed

sudo systemctl daemon-reload
sudo systemctl enable webapp.service
sudo systemctl start webapp.service

log "Systemd service enabled and started."

log "configure_permissions.sh script completed successfully."