# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.box = "squeeze"

  config.vm.forward_port 80, 50080
  config.vm.forward_port 443, 50443

  config.vm.provision :puppet do |puppet|
    puppet.manifest_file = "upgrade_puppet.pp"
  end

  config.vm.provision :puppet do |puppet|
    puppet.manifest_file = "pgci.pp"
    puppet.module_path = "modules"
  end

  config.vm.share_folder "pgci", "/srv/pgci", "."
end
