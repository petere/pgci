exec { 'jenkins':
  path => ['/usr/bin', '/bin'],
  command => 'puppet module install rafaelfc/jenkins',
  creates => '/etc/puppet/modules/jenkins/',
}
