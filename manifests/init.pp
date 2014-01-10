class zookeeper (
  $myid = $zookeeper::params::myid,
  $servers = $zookeeper::params::servers,
  $package_dir = $zookeeper::params::package_dir,
  $package_url = undef ) inherits zookeeper::params {

  class { 'zookeeper::package':
    package_dir => $package_dir,
    package_url => $package_url
  }

  require java

  group { "${zookeeper::params::group}":
    ensure => present,
    gid => "800"
  }

  user { "${zookeeper::params::user}":
    ensure => present,
    comment => "Zookeeper",
    password => "!!",
    uid => "800",
    gid => "800",
    shell => "/bin/bash",
    require => Group["${zookeeper::params::group}"],
  }

  file {"${zookeeper::params::datastore}":
    ensure => "directory",
    owner => "${zookeeper::params::user}",
    group => "${zookeeper::params::group}",
    alias => "zookeeper-datastore",
  }

  file {"${zookeeper::params::log_dir}":
    ensure => "directory",
    owner => "${zookeeper::params::user}",
    group => "${zookeeper::params::group}",
    alias => "zookeeper-log-dir",
  }

  file {"${zookeeper::params::install_dir}":
    ensure => "directory",
    mode => 0644,
    owner => "${zookeeper::params::user}",
    group => "${zookeeper::params::group}",
    alias => "zookeeper-install-dir",
  }

  file { "${zookeeper::params::install_dir}/${zookeeper::package::basefilename}":
    mode => 0644,
    owner => "${zookeeper::params::user}",
    group => "${zookeeper::params::group}",
    source => "file://${package_dir}/${zookeeper::package::basefilename}",
    alias => "zookeeper-source-tgz",
    before => Exec["untar-zookeeper"],
    require => File["zookeeper-install-dir"]
  }

  exec { "untar ${zookeeper::package::basefilename}":
    command => "tar xfvz ${zookeeper::package::basefilename}",
    cwd => "${zookeeper::params::install_dir}",
    creates => "${zookeeper::params::install_dir}/${zookeeper::package::basename}",
    alias => "untar-zookeeper",
    refreshonly => true,
    subscribe => File["zookeeper-source-tgz"],
    user => "${zookeeper::params::user}",
    before => [ File["zookeeper-symlink"], File["zookeeper-app-dir"]],
    path    => ["/bin", "/usr/bin", "/usr/sbin"],
  }

  file { "${zookeeper::params::install_dir}/${zookeeper::package::basename}":
    ensure => "directory",
    mode => 0644,
    owner => "${zookeeper::params::user}",
    group => "${zookeeper::params::group}",
    alias => "zookeeper-app-dir",
    require => Exec["untar-zookeeper"],
  }

  file { "${zookeeper::params::install_dir}/zookeeper":
    force => true,
    ensure => "${zookeeper::params::install_dir}/${zookeeper::package::basename}",
    alias => "zookeeper-symlink",
    owner => "${zookeeper::params::user}",
    group => "${zookeeper::params::group}",
    require => File["zookeeper-app-dir"],
    before => [ File["zoo-cfg"] ]
  }

  file {"${zookeeper::params::cfg_dir}":
    ensure => "directory",
    owner => "${zookeeper::params::user}",
    group => "${zookeeper::params::group}",
    alias => "zookeeper-cfg",
    require => [File["zookeeper-symlink"]],
    before => [ File["zoo-cfg"] ]
  }

  file { "${zookeeper::params::cfg_file}":
    owner => "${zookeeper::params::user}",
    group => "${zookeeper::params::group}",
    mode => "644",
    alias => "zoo-cfg",
    require => File["zookeeper-app-dir"],
    content => template("zookeeper/conf/zoo.cfg"),
  }

  file { "${zookeeper::params::datastore}/myid":
    owner => "${zookeeper::params::user}",
    group => "${zookeeper::params::group}",
    mode => "644",
    content => $myid,
    require => File["zookeeper-datastore"],
    alias => "zookeeper-myid",
  }

  file { "${cfg_dir}/environment":
    owner => "${zookeeper::params::user}",
    group => "${zookeeper::params::group}",
    mode => 755,
    content => template("zookeeper/conf/environment"),
    alias => 'zookeeper-environment'
  }

  file { "${cfg_dir}/zookeeper-env.sh":
    owner => "${zookeeper::params::user}",
    group => "${zookeeper::params::group}",
    mode => 755,
    content => template("zookeeper/conf/environment"),
    alias => 'zookeeper-envsh'
  }

  file { "/etc/init/zookeeper.conf":
    content => template("zookeeper/init/zookeeper.conf"),
    mode => "0644",
    alias => 'zookeeper-init',
    require => [File["zookeeper-myid"], File["zookeeper-environment"], File["zookeeper-envsh"]],
  }

  service { 'zookeeper':
    ensure => running,
    provider => 'upstart',
    require => File['zookeeper-init'],
  }

}