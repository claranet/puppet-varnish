# == Class varnish::service
#
# This class is meant to be called from varnish
# It ensure the service is running
#
class varnish::service {

  # This exec resource receives notifications from varnish::vcl resources
  exec { 'vcl_reload':
    command     => $::varnish::vcl_reload,
    path        => $::varnish::vcl_reload_path,
    refreshonly => true,
    require     => Service[$::varnish::service_name],
  }

  service { $::varnish::service_name:
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

}
