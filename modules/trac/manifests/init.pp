class trac {

  package { 'python-setuptools': }
  package { 'build-essential': }
  package { 'python-dev': }
  package { 'python-pip':
    require => [ Package['build-essential'], Package['python-dev'] ]
  }

  package { 'setuptools':
    provider => 'pip',
    require => Package['python-pip']
  }

  package { 'libsqlite3-dev': }
  package { 'pysqlite':
    provider => 'pip',
    require => [ Package['python-pip'], Package['setuptools'], Package['libsqlite3-dev'] ]
  }

  package { 'Genshi':
    ensure => '0.6',
    provider => 'pip',
    require => [ Package['python-pip'], Package['setuptools'] ]
  }

  package { 'trac':
    provider => 'pip',
    ensure => '0.11',
    require => [ Package['python-pip'], Package['setuptools'], Package['Genshi'] ]
  }

  exec { 'create_trac_env':
    command => "/usr/local/bin/trac-admin /vagrant/trac initenv 'My Project' 'sqlite:db/trac.db' 'svn' '/home/vagrant/repos'",
    unless => '/usr/bin/test -d /vagrant/trac',
    user => 'vagrant',
    require => Package['trac']
  }

  file { '/etc/init/trac.conf':
    source => 'puppet:///modules/trac/upstart_trac.conf'
  }

  service { 'trac':
    ensure => running,
    provider => 'upstart',
    require => [ Package['trac'], File['/etc/init/trac.conf'] ]
  }

}
