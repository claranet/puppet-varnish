node default {

  $version = '4.1'

  # == Package Versions

  case $::osfamily {
    'Debian': {
      if $::operatingsystem == 'Debian' and versioncmp($::lsbdistrelease,'8.0') >= 0 and $version == '3.0' {
        $package_ensure = '3.0.7-1~jessie'
      } elsif $::operatingsystem == 'Ubuntu' and versioncmp($::lsbdistrelease,'16.04') >= 0 and $version == '4.0' {
        $package_ensure = '4.0.5-1~xenial'
      } else {
        $package_ensure = 'present'
      }
    }

    'RedHat': {
      if $::operatingsystemmajrelease == '7' and $version == '4.0' {
        $package_ensure = '4.0.3-1.el7'
      } else {
        $package_ensure = 'present'
      }
    }

    default: {
      $package_ensure = 'present'
    }
  }

  # == Varnish

  class { '::varnish':
    varnish_version => $version,
    package_ensure  => $package_ensure,
    listen          => ['127.0.0.1:8890',"${::ipaddress}:8888"],
    storage_type    => 'malloc',
    storage_size    => '64M',
    instance_name   => "vagrant-varnish${version}",
  }

  # == Nginx + test file

  class { '::nginx':
    server_purge => true,
    confd_purge  => true,
  }

  if $::osfamily == 'Debian' {
    $nginx_port = 8080
  } else {
    $nginx_port = 80
  }

  ::nginx::resource::server { 'default':
    listen_port => $nginx_port,
    listen_ip   => '127.0.0.1',
    www_root    => '/usr/share/nginx/html',
  }

  file { '/usr/share/nginx/html/index.html':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "<html><head><title>Varnish</title></head><body>Hello, I am Varnish ${version} running on ${::hostname}</body></html>\n",
    require => Package['nginx'],
  }

}
