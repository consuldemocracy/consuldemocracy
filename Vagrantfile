Vagrant.configure("2") do |config|
  config.vm.box = "opscode_debian-8.1"
  config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_debian-8.1_chef-provisionerless.box"
  config.vm.hostname = "participacion"
  config.vm.network "forwarded_port", guest: 80, host: 8888
  config.vm.synced_folder '.', '/vagrant', owner: "www-data", group: "www-data"
  
  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 1
    v.customize ["modifyvm", :id, "--ioapic", "on"]
  end
  
  config.vm.provision :chef_solo do |chef|
    chef.log_level = ENV.fetch("CHEF_LOG", "info").downcase.to_sym
    chef.formatter = ENV.fetch("CHEF_FORMAT", "null").downcase.to_sym
    chef.add_recipe 'participacion'
    chef.cookbooks_path = 'chef'
    chef.json.merge!(JSON.parse(File.read("Vagrantfile.json")))
  end

end
