class build-deps {

  $build_deps = [ 'bison',
                  'flex',
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
                  'tcl-dev',

                  'lcov',

                  'docbook',
                  'docbook2x',
                  'docbook-dsssl',
                  'docbook-xsl',
                  'fop',
                  'jadetex',
                  'openjade1.3',
                  'opensp',
                  'texinfo',
                  'xsltproc',
                  ]

  package {
    $build_deps:
      ensure => installed;

    'ccache':
      ensure => installed;
  }

  file { ['/etc/texmf', '/etc/texmf/texmf.d']:
    ensure => directory,
  }

  file { '/etc/texmf/texmf.d/96JadeTeX.cnf':
    ensure => present,
    source => 'puppet:///modules/build-deps/jadetex.cnf',
    owner => root,
    group => root,
    notify => Exec['update-texmf'],
  }

  exec { 'update-texmf':
    path => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    refreshonly => true,
  }

}
