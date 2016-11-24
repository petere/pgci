# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.box = 'bento/debian-7.8'

  config.vm.hostname = 'pgci-vagrant'

  config.vm.network :forwarded_port, guest: 80, host: 50080
  config.vm.network :forwarded_port, guest: 443, host: 50443

  config.vm.provision :shell, inline: <<SCRIPT
if ! grep -q backports /etc/apt/sources.list; then
  echo 'deb http://httpredir.debian.org/debian wheezy-backports main' >>/etc/apt/sources.list
fi
apt-get update
apt-get -y -t wheezy-backports install puppet facter
SCRIPT

  config.vm.provision :puppet do |puppet|
    puppet.manifest_file = 'pgci.pp'
    puppet.module_path = 'modules'
    puppet.options = '--show_diff'
  end

  config.vm.synced_folder '.', '/srv/pgci'
end
