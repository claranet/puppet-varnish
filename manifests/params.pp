# == Class varnish::params
#
# This class is meant to be called from varnish
# It sets variables according to platform
#
class varnish::params {

  case $::osfamily {
    'RedHat': {

      $sysconfig  = '/etc/sysconfig/varnish'
      $vcl_reload = $::varnish::version_major ? {
        '5' => '/sbin/varnish_reload_vcl',
        '4' => '/usr/sbin/varnish_reload_vcl',
        '3' => '/bin/varnish_reload_vcl',
      }

      case $::operatingsystemmajrelease {

        '6': {
          $os_service_provider = 'sysvinit'
        }

        '7': {
          $os_service_provider = 'systemd'
        }

        default: {
          $os_service_provider = 'systemd'
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
      if versioncmp($::lsbdistrelease,'8.0') >= 0 {
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
