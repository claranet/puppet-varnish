# == Class varnish::params
#
# This class is meant to be called from varnish
# It sets variables according to platform
#
class varnish::params {

  $package_name = 'varnish'
  $service_name = 'varnish'

  case $::osfamily {
    'RedHat', 'Amazon': {

      case $::operatingsystemmajrelease {
        '6': {
          $addrepo            = true
          $repoclass          = "varnish::repo::el${::operatingsystemmajrelease}"
          $sysconfig          = '/etc/sysconfig/varnish'
          $varnish_version    = '3.0'
          $vcl_reload         = '/usr/bin/varnish_reload_vcl'
        }
        '7': {
          $addrepo            = true
          $repoclass          = "varnish::repo::el${::operatingsystemmajrelease}"
          $sysconfig          = '/etc/varnish/varnish.params'
          $varnish_version    = '4.0'
          $vcl_reload         = '/usr/sbin/varnish_reload_vcl'
        }
        default: {
          # Amazon Linux
          $addrepo            = true
          $repoclass          = "varnish::repo::el${::operatingsystemmajrelease}"
          $sysconfig          = '/etc/sysconfig/varnish'
          $varnish_version    = '3.0'
          $vcl_reload         = '/usr/bin/varnish_reload_vcl'
        }
      }
    }
    'Debian': {
      case $::lsbdistcodename {
        'precise': {
          $addrepo            = false
          $sysconfig          = '/etc/default/varnish'
          $varnish_version    = '3.0'
          $vcl_reload         = '/usr/share/varnish/reload-vcl'

        }
        'trusty': {
          $addrepo            = true
          $repoclass          = 'varnish::repo::debian'
          $sysconfig          = '/etc/default/varnish'
          $varnish_version    = '4.0'
          $vcl_reload         = '/usr/share/varnish/reload-vcl'

        }
        'wheezy': {
          $addrepo            = true
          $repoclass          = 'varnish::repo::debian'
          $sysconfig          = '/etc/default/varnish'
          $varnish_version    = '3.0'
          $vcl_reload         = '/usr/share/varnish/reload-vcl'

        }
        'jessie': {
          $addrepo            = true
          $repoclass          = 'varnish::repo::debian'
          $sysconfig          = '/etc/default/varnish'
          $varnish_version    = '4.0'
          $vcl_reload         = '/usr/share/varnish/reload-vcl'

        }
        default: {
          fail("${::operatingsystem} (${::lsbdistdescription}, ${::lsbdistcodename}) not supported")
        }
      }
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }

  # Standard Varnish sysconfig settings
  $vcl_conf       = '/etc/varnish/default.vcl'
  $listen         = '0.0.0.0'
  $listen_port    = 6081
  $admin_listen   = '127.0.0.1'
  $admin_port     = 6082
  $secret_file    = '/etc/varnish/secret'
  $min_threads    = 50
  $max_threads    = 1000
  $thread_timeout = 120
  $storage_type   = 'file'
  $storage_file   = '/var/lib/varnish/varnish_storage.bin'
  $storage_size   = '1G'
  $package_ensure = 'present'
  $ttl            = 120
}
