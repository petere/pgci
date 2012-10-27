class ferm {

  package {
    'ferm':
      ensure => installed,
  }

  file {
    '/etc/ferm':
      ensure  => directory,
      owner   => 'root',
      group   => 'adm',
      mode    => 'u=rwx,g=rxs,o=',
      require => Package['ferm'];

    '/etc/ferm/ferm.conf':
      ensure  => present,
      owner   => 'root',
      group   => 'adm',
      mode    => 'u=rw,go=r',
      notify  => Service['ferm'],
      source  => 'puppet:///modules/ferm/ferm.conf';
  }

  service {
    'ferm':
      ensure => running,
      require => Package['ferm'],
  }
}
