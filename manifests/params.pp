# == Class varnish::params
#
# This class is meant to be called from varnish
# It sets variables according to platform
#
class varnish::params {
  case $facts['os']['family'] {
    'RedHat': {
      $sysconfig  = '/etc/sysconfig/varnish'

      case $facts['os']['release']['major'] {
        '6': {
          $os_service_provider = 'sysvinit'
          $vcl_reload          = $varnish::version_major ? {
            '6' => '/usr/sbin/varnishreload',
            '5' => '/usr/sbin/varnish_reload_vcl',
            '4' => '/usr/sbin/varnish_reload_vcl',
            '3' => '/usr/bin/varnish_reload_vcl',
          }
        }

        '7': {
          $os_service_provider = 'systemd'
          $vcl_reload          = $varnish::version_major ? {
            '6' => '/usr/sbin/varnishreload',
            '5' => '/sbin/varnish_reload_vcl',
            '4' => '/usr/sbin/varnish_reload_vcl',
            '3' => '/usr/bin/varnish_reload_vcl',
          }
        }

        default: {
          $os_service_provider = 'systemd'
          $vcl_reload          = '/usr/sbin/varnish_reload_vcl'
        }
      }
    }

    'Debian': {
      $vcl_reload = $varnish::version_major ? {
        '6' => '/usr/sbin/varnishreload',
        '5' => '/usr/share/varnish/reload-vcl -q',
        '4' => '/usr/share/varnish/reload-vcl -q',
        '3' => '/usr/share/varnish/reload-vcl -q',
      }
      $sysconfig  = '/etc/default/varnish'

      case $facts['os']['name'] {
        'Ubuntu': {
          $systemd_version = '16.04'
        }
        'Debian': {
          $systemd_version = '8'
        }
        default: {
          fail("Unsupported Debian OS: ${facts['os']['name']}")
        }
      }

      if versioncmp($facts['os']['release']['full'], $systemd_version) >= 0 {
        $os_service_provider = 'systemd'
      } else {
        $os_service_provider = 'sysvinit'
      }
    }

    default: {
      fail("${facts['os']['family']} not supported")
    }
  }

  # == Service provider depends on Varnish version and OS

  if $varnish::version_major == '3' {
    if $facts['os']['name'] == 'Debian' {
      if versioncmp($facts['os']['release']['full'], '8.0') >= 0 {
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
