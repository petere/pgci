exec { 'jenkins':
  path => ['/usr/bin', '/bin'],
  command => 'puppet module install rafaelfc/jenkins',
  creates => '/etc/puppet/modules/jenkins/',
}

exec { 'apache':
  path => ['/usr/bin', '/bin'],
  command => 'puppet module install puppetlabs/apache',
  creates => '/etc/puppet/modules/apache/',
}
