# == Class varnish::service
#
# This class is meant to be called from varnish
# It ensure the service is running
#
class varnish::service {
  include varnish::params

  service { $varnish::params::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
