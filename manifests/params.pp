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
          $vcl_reload          = $::varnish::version_major ? {
            '6' => '/usr/sbin/varnishreload',
            '5' => '/usr/sbin/varnish_reload_vcl',
            '4' => '/usr/sbin/varnish_reload_vcl',
            '3' => '/usr/bin/varnish_reload_vcl',
          }
        }

        '7': {
          $os_service_provider = 'systemd'
          $vcl_reload          = $::varnish::version_major ? {
            '6' => '/usr/sbin/varnishreload',
            '5' => '/sbin/varnish_reload_vcl',
            '4' => '/usr/sbin/varnish_reload_vcl',
            '3' => '/usr/bin/varnish_reload_vcl',
          }
          $service_template    = $::varnish::version_major ? {
            '6' => 'varnish6.service.erb',
            '5' => 'varnish.service.erb',
            '4' => 'varnish.service.erb',
            '3' => 'varnish.service.erb',
          }
        }

        '8': {
          $os_service_provider = 'systemd'
          $vcl_reload          = $::varnish::version_major ? {
            '6' => '/usr/sbin/varnishreload',
            '5' => '/sbin/varnish_reload_vcl',
            '4' => '/usr/sbin/varnish_reload_vcl',
            '3' => '/usr/bin/varnish_reload_vcl',
          }
          $service_template    = $::varnish::version_major ? {
            '6' => 'varnish6.service.erb',
            '5' => 'varnish.service.erb',
            '4' => 'varnish.service.erb',
            '3' => 'varnish.service.erb',
          }
        }

        default: {
          $os_service_provider = 'systemd'
          $service_template    = 'varnish.service.erb'
          $vcl_reload          = '/usr/sbin/varnish_reload_vcl'
        }
      }
    }

    'Debian': {
      $vcl_reload = $::varnish::version_major ? {
        '6' => '/usr/sbin/varnishreload',
        '5' => '/usr/share/varnish/reload-vcl -q',
        '4' => '/usr/share/varnish/reload-vcl -q',
        '3' => '/usr/share/varnish/reload-vcl -q',
      }
      $sysconfig  = '/etc/default/varnish'

      case $::operatingsystem {
        'Ubuntu': {
          $systemd_version = '16.04'
        }
        'Debian': {
          $systemd_version = '8'
        }
        default: {
          fail("Unsupported Debian OS: ${::operatingsystem}")
        }
      }

      if versioncmp($::lsbdistrelease,$systemd_version) >= 0 {
        $os_service_provider = 'systemd'
        $service_template    = 'varnish.service.erb'
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
        $service_template = 'varnish.service.erb'
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
