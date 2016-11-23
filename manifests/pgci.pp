Package { ensure => installed }

file { '/etc/timezone':
  content => "Etc/UTC\n",
}

file { "/etc/localtime":
  source => "file:///usr/share/zoneinfo/Etc/UTC",
  links => follow,
  mode => 0644,
}


if $operatingsystem == 'Debian' {
  package { 'locales-all': }

  file { '/etc/default/locale':
    content => "LANG=en_US.UTF-8\n",
    require => Package['locales-all'],
  }

  # FIXME: needs alternative way to set locale on other OS
}


file { '/etc/apt/apt.conf.d/10periodic':
  content => "\
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

class { 'jenkins':
  config_hash => {
    'JAVA_ARGS' => { value => '-Xmx1000m -Dhudson.DNSMultiCast.disabled=true -Djava.awt.headless=true -Djenkins.install.runSetupWizard=false' },
    'JENKINS_ARGS' => { value => '--webroot=/var/cache/jenkins/war --httpPort=$HTTP_PORT --httpListenAddress=127.0.0.1 --prefix=$PREFIX' },
  },
  lts => true,
  version => held,
}
package { 'git': }

jenkins::plugin { 'analysis-core': }
jenkins::plugin { 'ansicolor': }
jenkins::plugin { 'antisamy-markup-formatter': }
jenkins::plugin { 'build-blocker-plugin': }
jenkins::plugin { 'clang-scanbuild-plugin': version => '1.4' }
jenkins::plugin { 'configurationslicing': }
jenkins::plugin { 'copyartifact': }
jenkins::plugin { 'description-setter': }
jenkins::plugin { 'depgraph-view': }
jenkins::plugin { 'disk-usage': }
jenkins::plugin { 'display-url-api': }
jenkins::plugin { 'git': }
jenkins::plugin { 'git-client': }
jenkins::plugin { 'github': }
jenkins::plugin { 'github-api': }
jenkins::plugin { 'googleanalytics': }
jenkins::plugin { 'htmlpublisher': }
jenkins::plugin { 'javadoc': }
jenkins::plugin { 'jquery': }
jenkins::plugin { 'jquery-ui': }
jenkins::plugin { 'junit': }
jenkins::plugin { 'mailer': }
jenkins::plugin { 'matrix-project': }
jenkins::plugin { 'maven-plugin': }
jenkins::plugin { 'multiple-scms': }
jenkins::plugin { 'plain-credentials': }
jenkins::plugin { 'port-allocator': }
jenkins::plugin { 'resource-disposer': }
jenkins::plugin { 'scm-api': }
jenkins::plugin { 'script-security': }
jenkins::plugin { 'sloccount': }
jenkins::plugin { 'ssh-credentials': }
jenkins::plugin { 'structs': }
jenkins::plugin { 'tap': }
jenkins::plugin { 'text-finder': }
jenkins::plugin { 'timestamper': }
jenkins::plugin { 'thinBackup': }
jenkins::plugin { 'token-macro': }
jenkins::plugin { 'view-job-filters': }
jenkins::plugin { 'warnings': }
jenkins::plugin { 'workflow-api': }
jenkins::plugin { 'workflow-basic-steps': }
jenkins::plugin { 'workflow-scm-step': }
jenkins::plugin { 'workflow-step-api': }
jenkins::plugin { 'ws-cleanup': }

package { 'graphviz': }  # for depgraph-view

class { 'apache':
  default_vhost => false,
}
class { 'apache::mod::proxy': }
class { 'apache::mod::proxy_http': }
class { 'apache::mod::ssl': }
apache::mod { 'rewrite': }

$custom_fragment = "\
ProxyPass         /jenkins  http://localhost:8080/jenkins nocanon
ProxyPassReverse  /jenkins  http://localhost:8080/jenkins
ProxyRequests     Off
AllowEncodedSlashes NoDecode

<Proxy http://localhost:8080/jenkins*>
  Order deny,allow
  Allow from all
</Proxy>

<Location /jenkins>
  Order deny,allow
  Allow from all
</Location>

RewriteEngine on
RewriteRule ^/$ jenkins/ [R]
"

apache::vhost { 'pgci':
  custom_fragment => $custom_fragment,
  docroot => '/var/www',
  port => 80,
}

apache::vhost { 'pgci-ssl':
  custom_fragment => $custom_fragment,
  docroot => '/var/www',
  port => 443,
  ssl => true,
  ssl_cert => '/etc/ssl/certs/ssl-cert-snakeoil.pem',
  ssl_key => '/etc/ssl/private/ssl-cert-snakeoil.key',
}

file { '/var/lib/jenkins/config.xml':
  source => '/srv/pgci/jenkins/config.xml',
  owner => jenkins,
  group => jenkins,
}

file { '/var/lib/jenkins/org.jenkinsci.main.modules.sshd.SSHD.xml':
  source => '/srv/pgci/jenkins/org.jenkinsci.main.modules.sshd.SSHD.xml',
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

if $fqdn != undef {
  file { '/etc/hostname':
    ensure => present,
    content => "$fqdn\n",
    notify => Exec['hostname'],
  }
}
else {
  warning("no FQDN defined")
}

exec { 'hostname':
  command => 'hostname -F /etc/hostname',
  path => ['/bin', '/usr/bin'],
  refreshonly => true,
  notify => Service['postfix'],
}

if $virtual != 'openvzve' {
  class { 'ntp': }
}

class { 'pgci_build_deps': }
class { 'pgci_ferm': }
class { 'pgci_icinga': }

case $operatingsystem {
  'Debian': { pgci_schroot { 'jessie': } }
  'Ubuntu': { pgci_schroot { 'saucy': mirror => 'http://archive.ubuntu.com/ubuntu' } }
}

# interferes with facter
package { 'procinfo':
  ensure => purged,
}

package { 'debian-goodies': }
package { 'sudo': }
