# == Class varnish::config
#
# This class is called from varnish
#
class varnish::config {

  case $::osfamily {
    'RedHat', 'Amazon': {
      case $::varnish::varnish_version {
        '3.0': {
          case $::operatingsystemmajrelease {
            '7': {
              $sysconfig_template = "varnish/el7/varnish-3.sysconfig.erb"
            }
            default: {
              $sysconfig_template = "varnish/el6/varnish-3.sysconfig.erb"
            }
          }
        }
        default: {
          case $::operatingsystemmajrelease {
            '7': {
              $sysconfig_template = "varnish/el7/varnish-3.sysconfig.erb"
            }
            default: {
              $sysconfig_template = "varnish/el6/varnish-3.sysconfig.erb"
            }
          }
        }
      }
    }

    'Debian': {
      case $::varnish::varnish_version {
        '3.0': {
          $sysconfig_template = 'varnish/debian/varnish-3.default.erb'
        }
        '4.0': {
          $sysconfig_template = 'varnish/debian/varnish-4.default.erb'
        }
        default: {
          fail("Varnish version ${::varnish::varnish_version} not supported on ${::operatingsystem} (${::lsbdistdescription}, ${::lsbdistcodename})")
        }
      }
    }

    default: {
      fail("Varnish version ${::varnish::varnish_version} not supported on ${::operatingsystem} (${::lsbdistdescription}, ${::lsbdistcodename})")
    }
  }

  file { $varnish::params::sysconfig:
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template($sysconfig_template),
  }

}
