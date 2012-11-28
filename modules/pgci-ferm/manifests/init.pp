class pgci-ferm {

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
      notify  => Exec['ferm-reload'],
      source  => 'puppet:///modules/pgci-ferm/ferm.conf';
  }

  exec {
    'ferm-reload':
      command => '/etc/init.d/ferm reload',
      refreshonly => true,
      require => Package['ferm'],
  }
}
