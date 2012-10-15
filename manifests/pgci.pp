class { 'jenkins': }
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
</Location>",

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
