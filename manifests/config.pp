# == Class varnish::config
#
# This class is called from varnish
#
class varnish::config {

  case $::varnish::varnish_version {
    '3.0': {
      $sysconfig_template = 'varnish/varnish-3.sysconfig.erb'
    }
    default: {
      $sysconfig_template = 'varnish/varnish-4.sysconfig.erb'
    }
  }

  file { $varnish::params::sysconfig:
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template($sysconfig_template),
  }

}
