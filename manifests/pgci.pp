Package { ensure => installed }

file { '/etc/timezone':
  content => 'Etc/UTC',
}

file { "/etc/localtime":
  source => "file:///usr/share/zoneinfo/Etc/UTC",
}

package { 'locales-all': }

file { '/etc/default/locale':
  content => "LANG=en_US.UTF-8\n",
  require => Package['locales-all'],
}

file { '/etc/apt/sources.list':
  ensure => absent,
  notify => Exec['apt_update'],
}

apt::source { "debian":
  location => "http://http.debian.net/debian/",
}

apt::source { "debian_security":
  location => "http://security.debian.org/",
  release => "$lsbdistcodename/updates",
}

Exec['apt_update'] -> Package <| |>

file { '/etc/apt/apt.conf.d/02periodic':
  content => "\
APT::Periodic::Enable \"1\";
APT::Periodic::Update-Package-Lists \"1\";
APT::Periodic::Download-Upgradeable-Packages \"1\";
APT::Periodic::AutocleanInterval \"1\";
",
}

if $virtual == 'virtualbox' {
  package { 'anacron': }
}

class { 'jenkins': }
package { 'git': }

# needed to run git inside jenkins
# see https://github.com/jenkinsci/jenkins/pull/591
user { 'jenkins':
  comment => 'Jenkins',
  require => Class['jenkins::package'],
  before => Class['jenkins::service'],
}

jenkins::plugin { 'configurationslicing': }
jenkins::plugin { 'depgraph-view': }
jenkins::plugin { 'git': }
jenkins::plugin { 'htmlpublisher': }
jenkins::plugin { 'timestamper': }
jenkins::plugin { 'thinBackup': }
jenkins::plugin { 'ws-cleanup': }

package { 'graphviz': }  # for depgraph-view

class { 'apache': }
class { 'apache::mod::proxy': }
class { 'apache::mod::proxy_http': }
class { 'apache::mod::ssl': }

file { '/etc/apache2': ensure => directory }
file { '/etc/apache2/conf.d': ensure => directory }

file { '/etc/apache2/conf.d/pgci':
  content => "\
<IfModule mod_proxy.c>
ProxyPass         /jenkins  http://localhost:8080/jenkins
ProxyPassReverse  /jenkins  http://localhost:8080/jenkins
ProxyRequests     Off

<Proxy http://localhost:8080/jenkins*>
  Order deny,allow
  Allow from all
</Proxy>

<Location /jenkins>
  Order deny,allow
  Allow from all
</Location>
</IfModule>

DocumentRoot /var/www",

  notify => Service['httpd'],
}

file { '/etc/apache2/conf.d/pgci-ssl':
  content => "\
<VirtualHost _default_:443>
<IfModule mod_ssl.c>
  SSLEngine on
  SSLCertificateFile    /etc/ssl/certs/ssl-cert-snakeoil.pem
  SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key
</IfModule>

  Include conf.d/pgci
</VirtualHost>",

  notify => Service['httpd'],
}

file { '/etc/default/jenkins':
  content => '
JAVA=/usr/bin/java
PIDFILE=/var/run/jenkins/jenkins.pid
JENKINS_USER=jenkins
JENKINS_WAR=/usr/share/jenkins/jenkins.war
JENKINS_HOME=/var/lib/jenkins
RUN_STANDALONE=true
JENKINS_LOG=/var/log/jenkins/jenkins.log
MAXOPENFILES=8192
HTTP_PORT=8080
AJP_PORT=-1
PREFIX=/jenkins
JENKINS_ARGS="--webroot=/var/cache/jenkins/war --httpPort=$HTTP_PORT --ajp13Port=$AJP_PORT --httpListenAddress=127.0.0.1 --prefix=$PREFIX"',

  backup => '.puppet-bak',
  before => Class["jenkins::service"],
}

package { 'icinga': }

service { 'icinga':
  ensure => running,
  require => Service['httpd'],
}

# http://projects.puppetlabs.com/issues/3299
exec { 'fix_nagios_perms':
  command => '/bin/chmod 0644 /etc/icinga/objects/puppet.cfg',
  before => Package['icinga'],
  notify => Service['icinga'],
  refreshonly => true,
}

file { ['/etc/icinga', '/etc/icinga/objects']:
  ensure => directory,
}

Nagios_command {
  notify => Exec['fix_nagios_perms'],
  target => '/etc/icinga/objects/puppet.cfg',
  require => File['/etc/icinga/objects'],
}

Nagios_host {
  notify => Exec['fix_nagios_perms'],
  target => '/etc/icinga/objects/puppet.cfg',
  require => File['/etc/icinga/objects'],
}

Nagios_service {
  notify => Exec['fix_nagios_perms'],
  target => '/etc/icinga/objects/puppet.cfg',
  require => File['/etc/icinga/objects'],
}

nagios_command { 'check_http_jenkins':
  command_line => "/usr/lib/nagios/plugins/check_http -H '\$HOSTADDRESS\$' -I '\$HOSTADDRESS\$' -u 'http://localhost/jenkins' -f follow -s 'Dashboard'",
}

nagios_command { 'check_mailq':
  command_line => "/usr/lib/nagios/plugins/check_mailq -w 10 -c 20 -M postfix",
}

nagios_command { 'check_ntp_time':
  command_line => "/usr/lib/nagios/plugins/check_ntp_time -H 0.debian.pool.ntp.org -w 0.5 -c 1",
}

nagios_command { 'check_swap':
  command_line => "/usr/lib/nagios/plugins/check_swap -w 90% -c 50%",
}

nagios_host { $hostname:
  use => 'generic-host',
  address => $ipaddress,
}

nagios_service { 'check_http':
  use => 'generic-service',
  host_name => $hostname,
  service_description => 'HTTP',
  check_command => 'check_http',
  require => [Nagios_host[$hostname],
              Service['httpd']],
}

nagios_service { 'check_https':
  use => 'generic-service',
  host_name => $hostname,
  service_description => 'HTTPS',
  check_command => 'check_https',
  require => [Nagios_host[$hostname],
              Service['httpd']],
}

nagios_service { 'check_http_jenkins_svc':
  use => 'generic-service',
  host_name => $hostname,
  service_description => 'HTTP Jenkins',
  check_command => 'check_http_jenkins',
  require => [Nagios_command['check_http_jenkins'],
              Nagios_host[$hostname],
              Service['httpd']],
}

nagios_service { 'check_apt':
  use => 'generic-service',
  host_name => 'localhost',
  service_description => 'APT',
  check_command => 'check_apt_distupgrade',
  require => Exec['apt_update'],
}

nagios_service { 'check_mailq_svc':
  use => 'generic-service',
  host_name => 'localhost',
  service_description => 'Mail queue',
  check_command => 'check_mailq',
  require => [Nagios_command['check_mailq'],
              Service['postfix']],
}

nagios_service { 'check_ntp_time_svc':
  use => 'generic-service',
  host_name => 'localhost',
  service_description => 'NTP',
  check_command => 'check_ntp_time',
  require => [Nagios_command['check_ntp_time'],
              Service['ntp']],
}

nagios_service { 'check_swap_svc':
  use => 'generic-service',
  host_name => 'localhost',
  service_description => 'Swap',
  check_command => 'check_swap',
  require => Nagios_command['check_swap'],
}

package { ['munin', 'munin-node']: }

file { '/etc/munin/apache.conf':
  ensure => present,
  content => "\
Alias /munin /var/cache/munin/www
<Directory /var/cache/munin/www>
    Allow from all
    <IfModule mod_expires.c>
        ExpiresActive On
        ExpiresDefault M310
    </IfModule>
</Directory>",
  notify => Service['httpd'],
  require => Package['munin'],
}

package { ['exim4-base', 'exim4-config', 'exim4-daemon-light']: ensure => purged }

package { 'postfix': }

service { 'postfix':
  ensure => running,
  require => Package['postfix'],
}

file { '/etc/postfix': ensure => directory }

file { '/etc/postfix/main.cf':
  ensure => present,
  content => "\
biff = no
inet_protocols = all
mynetworks_style = host",
  notify => Service['postfix'],
}

package { 'ntp': }
service { 'ntp':
  ensure => running,
  restart => '/etc/init.d/ntp reload',
  require => Package['ntp'],
}


# Build dependencies

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

package { $build_deps: }

package { 'ccache': }
