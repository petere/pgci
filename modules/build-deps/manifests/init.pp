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
                  'docbook-dsssl',
                  'docbook-xsl',
                  'openjade1.3',
                  'opensp',
                  'xsltproc',
                  ]

  package {
    $build_deps:
      ensure => installed;

    'ccache':
      ensure => installed;
  }

}
