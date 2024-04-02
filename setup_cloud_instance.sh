
# Redirect stdout and stderr to log files
exec > >(tee -a "$LOG_FILE") 2> >(tee -a "$ERROR_LOG_FILE" >&2)

# Update and install necessary packages
sudo yum install -y java-17-openjdk-devel
#sudo yum -y update
java -version
sudo yum install -y maven
mvn -version

sudo update-alternatives --set java $JAVA_HOME/bin/java
sudo update-alternatives --set javac $JAVA_HOME/bin/javac

sudo ln -sf /usr/lib/jvm/java-17-openjdk-17.0.6.0.9-0.3.ea.el8.x86_64/bin/java  /etc/alternatives/java

export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export PATH=$JAVA_HOME/bin:$PATH

# Set environment variables
source env_vars.sh

# Install unzip
sudo dnf install -y unzip

# Clean up
sudo yum clean all
sudo rm -rf /var/cache/yum

# unzip the required file to root directory
unzip webapp.zip

# ... (any other configurations you need)

sudo cp -r CloudAppRelease/assingment-0.0.1-SNAPSHOT.jar /opt
sudo cp -r CloudAppRelease/start.sh /opt
sudo cp -r CloudAppRelease/env_vars.sh /opt
sudo cp CloudAppRelease/webapp.service /etc/systemd/system

sudo groupadd csye6225
sudo useradd -s /usr/sbin/nologin -g csye6225 -d /opt -m csye6225
sudo chown -R csye6225:csye6225 /opt/
sudo chown csye6225:csye6225  /etc/systemd/system/webapp.service
#sudo mkdir /var/log/csye6225
#sudo chown csye6225:csye6225 /var/log/csye6225

sudo systemctl daemon-reload
sudo systemctl start webapp
sudo systemctl enable webapp