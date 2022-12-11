
Vagrant.configure("2") do |config|
  ### DB vm  ####
  config.vm.define "devops" do |devops|
    devops.vm.box = "centos/7"
    devops.vm.hostname = "database"
    devops.vm.network "private_network", ip: "192.168.33.21"
    devops.vm.network "public_network"
    devops.vm.synced_folder ".\\Devops", "/vagrant"
    config.vm.provider "virtualbox" do |vb|
     vb.memory = "1024"
    end
    devops.vm.provision "shell", inline: <<-SHELL
    sudo su - root
    yum update -y
    yum install epel-release -y
	sudo wget -O /etc/yum.repos.d/jenkins.repo \
	https://pkg.jenkins.io/redhat-stable/jenkins.repo -y
	sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
	sudo yum upgrade -y
	# Add required dependencies for the jenkins package
	sudo yum install java-11-openjdk -y
	sudo yum install jenkins -y
	sudo systemctl daemon-reload
    sudo firewall-cmd --permanent --add-service=http
    sudo firewall-cmd --permanent --add-service=https
    sudo firewall-cmd --reload
  SHELL
  end
end
