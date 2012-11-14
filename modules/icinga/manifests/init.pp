class icinga {

  package {
    'icinga':
      ensure => installed,
  }

  file {
    ['/etc/icinga', '/etc/icinga/objects']:
      ensure => directory,
      require => Package ['icinga'];

    '/etc/icinga/objects/pgci.cfg':
      ensure => present,
      content => template('icinga/pgci.cfg.erb'),
      notify => Service['icinga'];
  }

  service {
    'icinga':
      ensure => running,
      require => Service['httpd', 'postfix'],
  }
}
