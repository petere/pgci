# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "debian-710-x64-vbox4210-nocm"

  config.vm.hostname = "pgci-vagrant"

  config.vm.network :forwarded_port, guest: 80, host: 50080
  config.vm.network :forwarded_port, guest: 443, host: 50443

  config.vm.provision :shell, :inline => 'apt-get -qq update && apt-get -qqy install puppet facter'

  config.vm.provision :puppet do |puppet|
    puppet.manifest_file = "pgci.pp"
    puppet.module_path = "modules"
    puppet.options = "--show_diff"
  end

  config.vm.synced_folder ".", "/srv/pgci"
end
