class pgci-build-deps {

  $clang = $lsbdistcodename ? {
    jessie => 'clang-3.3',
    saucy => 'clang-3.3',
    default => 'clang'
  }

  $build_deps = [ 'bison',
                  $clang,
                  'flex',
                  'g++',
                  'gcc',
                  'gettext',
                  'libedit-dev',
                  'libkrb5-dev',
                  'libldap2-dev',
                  'libossp-uuid-dev',
                  'libpam0g-dev',
                  'libperl-dev',
                  'libreadline-dev',
                  'libssl-dev',
                  'libxml2-dev',
                  'libxslt1-dev',
                  'zlib1g-dev',
                  'make',
                  'perl',
                  'python-dev',
                  'python3-dev',
                  'systemtap-sdt-dev',
                  'tcl-dev',

                  'lcov',

                  'dbtoepub',
                  'docbook',
                  'docbook2x',
                  'docbook-dsssl',
                  'docbook-xsl',
                  'fop',
                  'jadetex',
                  'lynx',
                  'openjade1.3',
                  'opensp',
                  'texinfo',
                  'xsltproc',

                  'curl',
                  'libmemcached-dev',
                  'libv8-dev',
                  'pkg-config',
                  'python-docutils', # for pghashlib
                  'r-base-core',
                  'time',
                  'uuid-dev',
                  'wget',
                  ]

  package {
    $build_deps:
      ensure => installed;

    'ccache':
      ensure => installed;
  }


  if $operatingsystem == 'Debian' and $is_chroot == 'true' {
    package { 'locales-all': }
  }


  if $lsbdistcodename == 'squeeze' {
    apt::pin { 'squeeze-backports':
      packages => ['fop', 'libfop-java'],
      priority => 500,
      before => Package['fop'],
    }
  }


  file { ['/etc/texmf', '/etc/texmf/texmf.d']:
    ensure => directory,
  }

  file { '/etc/texmf/texmf.d/96JadeTeX.cnf':
    ensure => present,
    source => 'puppet:///modules/pgci-build-deps/jadetex.cnf',
    owner => root,
    group => root,
    notify => Exec['update-texmf'],
    require => Package['jadetex'],
  }

  exec { 'update-texmf':
    path => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    refreshonly => true,
  }

}
