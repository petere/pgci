define puppetmodule ($user = 'puppetlabs') {
  exec { "$name":
    path => ['/usr/bin', '/bin'],
    command => "puppet module install $user/$name",
    creates => "/etc/puppet/modules/$name/",
  }
}

puppetmodule { 'apache': }
puppetmodule { 'apt': }
puppetmodule { 'jenkins': user => 'rafaelfc' }
