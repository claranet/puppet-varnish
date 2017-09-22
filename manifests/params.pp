# == Class varnish::params
#
# This class is meant to be called from varnish
# It sets variables according to platform
#
class varnish::params {

  case $::osfamily {
    'RedHat': {

      $sysconfig  = '/etc/sysconfig/varnish'

      case $::operatingsystemmajrelease {

        '6': {
          $os_service_provider = 'sysvinit'
          $vcl_reload          = 'varnish_reload_vcl'
        }

        '7': {
          $os_service_provider = 'systemd'

          if "${::varnish::version_major}.${::varnish::version_minor}" == '5.1' {
            $vcl_reload = '/sbin/varnish_reload_vcl'
          } else {
            $vcl_reload = 'varnish_reload_vcl'
          }
        }

        default: {
          $os_service_provider = 'systemd'
          $vcl_reload          = 'varnish_reload_vcl'
        }
      }
    }

    'Debian': {
      $vcl_reload = '/usr/share/varnish/reload-vcl'
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
        $os_service_provider = 'systemd'
      } else {
        $os_service_provider = 'sysvinit'
      }
    }

    default: {
      fail("${::osfamily} not supported")
    }
  }

  # == Service provider depends on Varnish version and OS

  if $::varnish::version_major == '3' {
    if $::operatingsystem == 'Debian' {
      if versioncmp($::lsbdistrelease,'8.0') >= 1 {
        $service_provider = 'systemd'
      } else {
        $service_provider = 'sysvinit'
      }
    } else {
      $service_provider = 'sysvinit'
    }
  } else {
    $service_provider = $os_service_provider
  }

}
