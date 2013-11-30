class pgci-schroot::prereqs {
  package {
    ['debootstrap', 'schroot']:
      ensure => installed,
  }

  file{
    '/etc/schroot/jenkins':
      ensure => directory;
    '/etc/schroot/jenkins/fstab':
      ensure => present,
      content => template('pgci-schroot/schroot-fstab.erb');
  }
}
