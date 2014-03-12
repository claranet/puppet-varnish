# == Class varnish::config
#
# This class is called from varnish
#
class varnish::config {

  file { $varnish::params::sysconfig:
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('varnish/varnish.sysconfig.erb'),
  }

}
