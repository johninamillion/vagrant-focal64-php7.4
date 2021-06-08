Vagrant.configure(2) do |config|

  config.vm.box = "ubuntu/focal64"
  config.vm.box_check_update = true

  config.vm.network :forwarded_port, guest: 80, host: 8080, auto_correct: true
  config.vm.network "public_network"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.name = "vagrant-focal64-php7.4"
    vb.memory = "1024"
  end

  config.vm.provision "shell" do |shell|
    shell.path ="./vagrant/build.sh"
    shell.path ="./vagrant/custom.sh"
  end

 config.trigger.after :up do
    system("open", "http://localhost:8080")
 end

 config.vm.synced_folder "./sync", "/var/www", owner: "vagrant", group: "vagrant"

end
