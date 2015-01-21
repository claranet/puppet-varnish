# == Class varnish::params
#
# This class is meant to be called from varnish
# It sets variables according to platform
#
class varnish::params {
  case $::osfamily {
    'RedHat', 'Amazon': {
      $package_name = 'varnish'
      $service_name = 'varnish'
      $vcl_reload   = '/usr/bin/varnish_reload_vcl'
      case $::operatingsystemmajrelease {
        '6': {
          $repoclass       = "varnish::repo::el${::operatingsystemmajrelease}"
          $sysconfig       = '/etc/sysconfig/varnish'
          $varnish_version = '3.0'
        }
        '7': {
          $repoclass       = "varnish::repo::el${::operatingsystemmajrelease}"
          $sysconfig       = '/etc/varnish/varnish.params'
          $varnish_version = '4.0'
        }
        default: {
          # Amazon Linux
          $repoclass       = "varnish::repo::el${::operatingsystemmajrelease}"
          $sysconfig       = '/etc/sysconfig/varnish'
          $varnish_version = '3.0'
        }
      }
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }

  # Standard Varnish sysconfig settings
  $vcl_conf         = '/etc/varnish/default.vcl'
  $listen           = '0.0.0.0'
  $listen_port      = 6081
  $admin_listen     = '127.0.0.1'
  $admin_port       = 6082
  $secret_file      = '/etc/varnish/secret'
  $min_threads      = 50
  $max_threads      = 1000
  $thread_timeout   = 120
  $storage_type     = 'file'
  $storage_file     = '/var/lib/varnish/varnish_storage.bin'
  $storage_size     = '1G'
  $specific_version = '3.0.5-1.el6'
}
