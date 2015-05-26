# == Class varnish::service
#
# This class is meant to be called from varnish
# It ensure the service is running
#
class varnish::service {
  include varnish
  include varnish::params

  service { $varnish::params::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
  
  # This exec resource receives notifications from varnish::vcl resources
  exec { 'vcl_reload':
    command     => $varnish::vcl_reload,
    refreshonly => true,
  }

}
