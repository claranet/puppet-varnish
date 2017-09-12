# == Class varnish::config
#
# This class is called from varnish
#
class varnish::config {

  $varnish_available = $::varnish_version
  if $varnish::package_ensure =~ /\d/ {
    $config_version = $varnish::package_ensure
  }
  elsif (addrepo == false or
    versioncmp($varnish_available, $varnish::varnish_version) > 0) {
      $config_version = $varnish_available
  }
  else {
    $config_version = $varnish::varnish_version
  }

  case $::osfamily {
    'RedHat', 'Amazon': {
      case $config_version {
        /3.[0-1]/: {
          $sysconfig_template = "varnish/el${::operatingsystemmajrelease}/varnish-3.sysconfig.erb"
        }
        default: {
          $sysconfig_template = "varnish/el${::operatingsystemmajrelease}/varnish-4.sysconfig.erb"
        }
      }
    }

    'Debian': {
      case $config_version {
        /3.[0-1]/: {
          $sysconfig_template = 'varnish/debian/varnish-3.default.erb'
        }
        /4.[0-1]/: {
          $sysconfig_template = 'varnish/debian/varnish-4.default.erb'
        }
        default: {
          fail("Varnish version ${config_version} not supported on ${::operatingsystem} (${::lsbdistdescription}, ${::lsbdistcodename})")
        }
      }
    }

    default: {
      fail("Varnish version ${config_version} not supported on ${::operatingsystem} (${::lsbdistdescription}, ${::lsbdistcodename})")
    }
  }

  file { $varnish::params::sysconfig:
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template($sysconfig_template),
  }

}
