# == Class varnish::install
#
class varnish::install {
  include ::varnish::params

  package { $varnish::params::package_name:
    ensure => $varnish::package_ensure,
  }
}
