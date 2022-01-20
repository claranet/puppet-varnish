node default {
  $version = '6.0lts'

  # == Package Versions

  case $facts['os']['family'] {
    'Debian': {
      if $facts['os']['name'] == 'Debian' and versioncmp($facts['os']['release']['full'] , '8.0') >= 0 and $version == '3.0' {
        $package_ensure = '3.0.7-1~jessie'
      } elsif $facts['os']['name'] == 'Ubuntu' and versioncmp($facts['os']['release']['full'], '16.04') >= 0 and $version == '4.0' {
        $package_ensure = '4.0.5-1~xenial'
      } else {
        $package_ensure = 'present'
      }
    }

    'RedHat': {
      if $facts['os']['release']['major'] == '7' and $version == '4.0' {
        $package_ensure = '4.0.4-1.el7'
      } else {
        $package_ensure = 'present'
      }
    }

    default: {
      $package_ensure = 'present'
    }
  }

  # == Varnish

  class { 'varnish':
    varnish_version    => $version,
    package_ensure     => $package_ensure,
    listen             => ['127.0.0.1:8888',"${facts['networking']['ip']}:6081"],
    storage_additional => ['file,/var/lib/varnish/varnish_additional.bin,1G'],
    storage_type       => 'malloc',
    storage_size       => '64M',
    instance_name      => "vagrant-varnish${version}",
  }

  # == Nginx + test file

  class { 'nginx':
    server_purge => true,
    confd_purge  => true,
  }

  if $facts['os']['family'] == 'Debian' {
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
    content => "<html><head><title>Varnish</title></head><body>Hello, I am Varnish ${version} running on ${facts['networking']['hostname']}</body></html>\n",
    require => Package['nginx'],
  }
}
