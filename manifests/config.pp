# == Class varnish::config
#
# This class is called from varnish
#
class varnish::config {

  $sysconfig_template = $::varnish::params::sysconfig_template

  file { $varnish::params::sysconfig:
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template($sysconfig_template),
  }

}
