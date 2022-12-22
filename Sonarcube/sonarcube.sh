#!/bin/bash
sudo apt-get update -y
sudo apt-get install systemd -y
sudo cp /etc/sysctl.conf /root/sysctl.conf_backup
sudo cat <<EOT> /etc/sysctl.conf
vm.max_map_count=262144
fs.file-max=65536
ulimit -n 65536
ulimit -u 4096
EOT

sudo cp /etc/security/limits.conf /root/sec_limit.conf_backup
sudo cat <<EOT> /etc/security/limits.conf
sonarqube   -   nofile   65536
sonarqube   -   nproc    409
EOT

sudo add-apt-repository ppa:openjdk-r/ppa -y
sudo apt-get update -y
sudo apt install openjdk-11-jdk -y
sudo update-alternatives --config java

sudo apt update -y
sudo apt install postgresql postgresql-contrib -y
sudo service postgresql start
sudo service postgresql status
sudo -i -u postgres psql -c "CREATE DATABASE sonarqube;"
sudo service postgresql status

sudo mkdir -p /sonarqube/
sudo cd /sonarqube/
sudo curl -O https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.3.0.34182.zip

sudo apt-get install zip -y
sudo unzip -o sonarqube-8.3.0.34182.zip -d /opt/
sudo mv /opt/sonarqube-8.3.0.34182/ /opt/sonarqube
sudo groupadd sonar
sudo useradd -c "SonarQube - User" -d /opt/sonarqube/ -g sonar sonar
sudo chown sonar:sonar /opt/sonarqube/ -R
sudo cp /opt/sonarqube/conf/sonar.properties /root/sonar.properties_backup

sudo cat <<EOT> /opt/sonarqube/conf/sonar.properties
sonar.jdbc.username=sonar
sonar.jdbc.password=admin123
sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
sonar.web.host=0.0.0.0
sonar.web.port=9000
sonar.web.javaAdditionalOpts=-server
sonar.search.javaOpts=-Xmx512m -Xms512m -XX:+HeapDumpOnOutOfMemoryError
sonar.log.level=INFO
sonar.path.logs=logs
EOT

sudo cat <<EOT> /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=syslog.target network.target
[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonar
Group=sonar
Restart=always
LimitNOFILE=65536
LimitNPROC=4096
[Install]
WantedBy=multi-user.target
EOT

sudo apt-get install nginx -y
sudo rm -rf /etc/nginx/sites-enabled/default
sudo rm -rf /etc/nginx/sites-available/default

sudo cat <<EOT> /etc/nginx/sites-available/sonarqube
server{
    listen      80;
    server_name sonarqube.groophy.in;
    access_log  /var/log/nginx/sonar.access.log;
    error_log   /var/log/nginx/sonar.error.log;
    proxy_buffers 16 64k;
    proxy_buffer_size 128k;
    location / {
        proxy_pass  http://127.0.0.1:9000;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_redirect off;
              
        proxy_set_header    Host            \$host;
        proxy_set_header    X-Real-IP       \$remote_addr;
        proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto http;
    }
}
EOT

sudo ln -s /etc/nginx/sites-available/sonarqube /etc/nginx/sites-enabled/sonarqube
sudo fuser -k 80/tcp
sudo service nginx start
sudo service nginx status
sudo systemctl start sonarqube.service
sudo systemctl status sonarqube.service
sudo service postgresql status
sudo ufw allow 80,9000,9001/tcp
echo "System reboot in 30 sec"
sudo sleep 30
sudo reboot
