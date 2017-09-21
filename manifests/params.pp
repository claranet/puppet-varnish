# == Class varnish::params
#
# This class is meant to be called from varnish
# It sets variables according to platform
#
class varnish::params {

  case $::osfamily {
    'RedHat': {
      $reload_vcl = 'varnish_reload_vcl'
      $sysconfig  = '/etc/sysconfig/varnish'

      case $::operatingsystemmajrelease {
        '6': {
          $service_provider = 'sysvinit'
        }

        default: {
          $service_provider = 'systemd'
        }
      }
    }

    'Debian': {
      $reload_vcl = '/usr/share/varnish/reload-vcl'
      $sysconfig  = '/etc/default/varnish'

      case $::operatingsystem {
        'Ubuntu': {
          $systemd_version = '16.04'
        }
        'Debian': {
          $systemd_version = '8.0'
        }
        default: {
          fail("Unsupported Debian OS: ${::operatingsystem}")
        }
      }

      if versioncmp($::lsbdistrelease,$systemd_version) >= 0 {
        $service_provider = 'systemd'
      } else {
        $service_provider = 'sysvinit'
      }
    }

    default: {
      fail("${::osfamily} not supported")
    }
  }
}
