# == Class varnish::params
#
# This class is meant to be called from varnish
# It sets variables according to platform
#
class varnish::params {

  case $::osfamily {
    'RedHat': {
      $sysconfig  = '/etc/sysconfig/varnish'
    }
    'Debian': {
      $sysconfig  = '/etc/default/varnish'
    }
    default: {
      fail("${::osfamily} not supported")
    }
  }

  $varnish_version = '4.1'
  $addrepo         = true
  $vcl_conf        = '/etc/varnish/default.vcl'
  $listen          = '0.0.0.0'
  $listen_port     = '6081'
  $admin_listen    = '127.0.0.1'
  $admin_port      = '6082'
  $secret_file     = '/etc/varnish/secret'
  $min_threads     = '50'
  $max_threads     = '1000'
  $thread_timeout  = '120'
  $storage_type    = 'file'
  $storage_file    = '/var/lib/varnish/varnish_storage.bin'
  $storage_size    = '1G'
  $package_ensure  = 'present'
  $package_name    = 'varnish'
  $service_name    = 'varnish'
  $vcl_reload      = 'varnish_reload_vcl'
}
