Package { ensure => installed }

class { 'jenkins': }
class { 'jenkins::git': }

# needed to run git inside jenkins
# see https://github.com/jenkinsci/jenkins/pull/591
user { 'jenkins':
  comment => 'Jenkins',
  require => Class['jenkins::package'],
  before => Class['jenkins::service'],
}

class { 'apache': }
class { 'apache::mod::proxy': }
class { 'apache::mod::proxy_http': }

file { '/etc/apache2': ensure => directory }
file { '/etc/apache2/conf.d': ensure => directory }

file { '/etc/apache2/conf.d/pgci':
  content => "\
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

DocumentRoot /var/www",

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
}

# http://projects.puppetlabs.com/issues/3299
exec { 'fix_nagios_perms':
  command => '/bin/chmod 0644 /etc/icinga/objects/puppet.cfg',
  notify => Service['icinga'],
  refreshonly => true,
}

Nagios_command {
  notify => Exec['fix_nagios_perms'],
  target => '/etc/icinga/objects/puppet.cfg',
  require => Package['icinga'],
}

Nagios_service {
  notify => Exec['fix_nagios_perms'],
  target => '/etc/icinga/objects/puppet.cfg',
  require => Package['icinga'],
}

nagios_command { 'check_http_jenkins':
  command_line => "/usr/lib/nagios/plugins/check_http -H '\$HOSTADDRESS\$' -I '\$HOSTADDRESS\$' -u 'http://localhost/jenkins' -f follow -s 'Dashboard'",
}

nagios_service { 'check_http_jenkins_svc':
  use => 'generic-service',
  host_name => 'localhost',
  service_description => 'HTTP Jenkins',
  check_command => 'check_http_jenkins',
  require => Nagios_Command['check_http_jenkins'],
}

package { ['exim4-base', 'exim4-config', 'exim4-daemon-light']: ensure => purged }

package { 'postfix': }

service { 'postfix':
  ensure => running,
  restart => 'postfix reload',
  require => Package['postfix'],
}

file { '/etc/postfix': ensure => directory }

file { '/etc/postfix/main.cf':
  ensure => present,
  content => "\
biff = no
mynetworks_style = host",
  notify => Service['postfix'],
}
