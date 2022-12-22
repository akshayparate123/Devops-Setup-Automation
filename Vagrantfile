
Vagrant.configure("2") do |config|
  ### DB vm  ####
  config.ssh.forward_agent = true
  config.vm.define "jenkins" do |jenkins|
    jenkins.vm.box = "centos/7"
    jenkins.vm.hostname = "jenkins"
    jenkins.vm.network "private_network", ip: "192.168.33.21"
    jenkins.vm.network "public_network"
    jenkins.vm.synced_folder ".\\Jenkins", "/vagrant"
    config.vm.provider "virtualbox" do |vb|
     vb.memory = "512"
    end
    jenkins.vm.provision "shell", inline: <<-SHELL
    sudo su - root
    yum update -y
    yum install epel-release -y
	sudo yum install wget -y
	sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
	sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
	sudo yum upgrade -y
	# Add required dependencies for the jenkins package
	sudo yum install java-11-openjdk -y
	#yum install java-1.8.0-openjdk -y
	sudo yum install jenkins -y
	sudo systemctl enable jenkins
	sudo systemctl start jenkins
	sudo systemctl status jenkins
	sudo systemctl daemon-reload
    sudo firewall-cmd --permanent --add-service=http
    sudo firewall-cmd --permanent --add-service=https
    sudo firewall-cmd --reload
  SHELL
  end
  
  config.vm.define "nexus" do |nexus|
    nexus.vm.box = "centos/7"
    nexus.vm.hostname = "nexus"
    nexus.vm.network "private_network", ip: "192.168.33.22"
    nexus.vm.network "public_network"
    nexus.vm.synced_folder ".\\Nexus", "/vagrant"
    config.vm.provider "virtualbox" do |vb|
     vb.memory = "512"
    end
    nexus.vm.provision "shell", path: "Nexus/nexus.sh"
	end
	
  config.vm.define "sonarqube" do |sonarqube|
    sonarqube.vm.box = "ubuntu/trusty64"
    sonarqube.vm.hostname = "sonarqube"
    sonarqube.vm.network "private_network", ip: "192.168.33.23"
    sonarqube.vm.network "public_network"
    sonarqube.vm.synced_folder ".\\Sonarcube", "/vagrant"
    config.vm.provider "virtualbox" do |vb|
     vb.memory = "512"
    end
    sonarqube.vm.provision "shell", path: "Sonarcube/sonarcube.sh"
	end
	
end
