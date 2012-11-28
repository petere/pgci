Package { ensure => installed }

file { '/etc/timezone':
  content => "Etc/UTC\n",
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

apt::source { "debian_backports":
  location => "http://http.debian.net/debian-backports/",
  release => "$lsbdistcodename-backports",
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

package { ['samba', 'smbfs']: ensure => purged }

package { ['deborphan']: }

class { 'jenkins': }
package { 'git': }

# needed to run git inside jenkins
# see https://github.com/jenkinsci/jenkins/pull/591
user { 'jenkins':
  comment => 'Jenkins',
  gid => 'jenkins',
  system => true,
  require => Class['jenkins::package'],
  before => Class['jenkins::service'],
}

group { 'jenkins':
  system => true,
}

jenkins::plugin { 'analysis-core': }
jenkins::plugin { 'configurationslicing': }
jenkins::plugin { 'copyartifact': }
jenkins::plugin { 'depgraph-view': }
jenkins::plugin { 'git': }
jenkins::plugin { 'googleanalytics': }
jenkins::plugin { 'htmlpublisher': }
jenkins::plugin { 'text-finder': }
jenkins::plugin { 'timestamper': }
jenkins::plugin { 'thinBackup': }
jenkins::plugin { 'warnings': }
jenkins::plugin { 'ws-cleanup': }

package { 'graphviz': }  # for depgraph-view

class { 'apache': }
class { 'apache::mod::proxy': }
class { 'apache::mod::proxy_http': }
class { 'apache::mod::ssl': }
apache::mod { 'rewrite': }

file { '/etc/apache2': ensure => directory }
file { '/etc/apache2/conf.d': ensure => directory }

file { '/etc/apache2/ports.conf':
  content => "\
Listen 80
Listen 443
",

  notify => Service['httpd'],
}

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

DocumentRoot /var/www

RewriteEngine on
RewriteRule ^/$ jenkins/ [R]
",

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
</VirtualHost>
",

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
JAVA_ARGS="-Dhudson.tasks.ArtifactArchiver.warnOnEmpty=true"
JENKINS_ARGS="--webroot=/var/cache/jenkins/war --httpPort=$HTTP_PORT --ajp13Port=$AJP_PORT --httpListenAddress=127.0.0.1 --prefix=$PREFIX"
',

  backup => '.puppet-bak',
  before => Class["jenkins::service"],
}

file { '/var/lib/jenkins':
  ensure => directory,
  recurse => remote,
  source => '/srv/pgci/jenkins',
  owner => jenkins,
  group => jenkins,
}

# to override jenkins plugin
file { '/var/lib/jenkins/plugins':
  ensure => directory,
  owner => jenkins,
  group => jenkins,
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
</Directory>
",
  notify => Service['httpd'],
  require => Package['munin'],
}

package { ['exim4-base', 'exim4-config', 'exim4-daemon-light']: ensure => purged }
package { ['sendmail-base', 'sendmail-bin', 'sendmail-cf', 'sendmail-doc']: ensure => purged }

package { 'postfix': }

service { 'postfix':
  ensure => running,
  require => Package['postfix'],
}

file { '/etc/postfix': ensure => directory }

file { '/etc/postfix/main.cf':
  ensure => present,
  content => "\
append_dot_mydomain = no
biff = no
inet_protocols = all
mynetworks_style = host
",
  notify => Service['postfix'],
}

file { '/etc/hostname':
  ensure => present,
  content => "$fqdn\n",
  notify => Exec['hostname'],
}

exec { 'hostname':
  command => 'hostname -F /etc/hostname',
  path => ['/bin', '/usr/bin'],
  refreshonly => true,
  notify => Service['postfix'],
}

if $virtual != 'openvzve' {
  package { 'ntp': }
  service { 'ntp':
    ensure => running,
    restart => '/etc/init.d/ntp reload',
    require => Package['ntp'],
  }
}

class { 'build-deps': }
class { 'ferm': }
class { 'icinga': }

# interferes with facter
package { 'procinfo':
  ensure => purged,
}
