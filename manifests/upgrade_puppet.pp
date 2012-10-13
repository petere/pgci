exec { 'puppetlabs-release':
  path => ["/usr/bin", "/usr/sbin", "/bin", "/sbin"],
  command => "sh -c 'cd /tmp && wget http://apt.puppetlabs.com/puppetlabs-release-${lsbdistcodename}.deb && dpkg -i puppetlabs-release-${lsbdistcodename}.deb && apt-get update'",
  creates => "/tmp/puppetlabs-release-${lsbdistcodename}.deb",
}

package { 'puppet':
  ensure => latest,
  require => Exec['puppetlabs-release'],
}
