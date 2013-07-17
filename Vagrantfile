# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.box = "debian-710-x64-vbox4210-nocm"

  config.vm.forward_port 80, 50080
  config.vm.forward_port 443, 50443

  config.vm.provision :shell, :inline => 'apt-get -qy install puppet facter'

  config.vm.provision :puppet do |puppet|
    puppet.manifest_file = "pgci.pp"
    puppet.module_path = "modules"
  end

  config.vm.share_folder "pgci", "/srv/pgci", "."
end
