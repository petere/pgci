# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.box = "squeeze"

  config.vm.forward_port 80, 50080
  config.vm.forward_port 443, 50443

  # Get puppet and facter from squeeze backports.  Some of the
  # manifests and modules don't work with the default versions in
  # squeeze.
  config.vm.provision :shell, :inline => '( puppet --version | grep -q 2.7 && facter --version | grep -q 1.6 ) || ( echo "deb http://http.debian.net/debian-backports squeeze-backports main" >> /etc/apt/sources.list && apt-get -qy update && apt-get -qy install -t squeeze-backports puppet facter )'

  config.vm.provision :puppet do |puppet|
    puppet.manifest_file = "pgci.pp"
    puppet.module_path = "modules"
  end

  config.vm.share_folder "pgci", "/srv/pgci", "."
end
