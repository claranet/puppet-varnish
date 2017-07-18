# == Class varnish::config
#
# This class is called from varnish
#
class varnish::config {

  case $::osfamily {
    'RedHat', 'Amazon': {
      case $::varnish::varnish_version {
        /3.[0-1]/: {
          $sysconfig_template = "varnish/el${::operatingsystemmajrelease}/varnish-3.sysconfig.erb"
        }
        default: {
          $sysconfig_template = "varnish/el${::operatingsystemmajrelease}/varnish-4.sysconfig.erb"
        }
      }
    }

    'Debian': {
      case $::varnish::varnish_version {
        /3.[0-1]/: {
          $sysconfig_template = 'varnish/debian/varnish-3.default.erb'
        }
        /4.[0-1]/: {
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
