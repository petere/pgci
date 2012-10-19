# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.box = "squeeze"

  config.vm.forward_port 80, 50080

  config.vm.provision :puppet do |puppet|
    puppet.manifest_file = "upgrade_puppet.pp"
  end

  config.vm.provision :puppet do |puppet|
    puppet.manifest_file = "puppet_modules.pp"
  end

  config.vm.provision :puppet do |puppet|
    puppet.manifest_file = "pgci.pp"
  end

  config.vm.share_folder "pgci", "/srv/pgci", "."
end
