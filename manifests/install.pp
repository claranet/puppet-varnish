# == Class varnish::install
#
class varnish::install {
  package { $::varnish::params::package_name:
    ensure  => $::varnish::package_ensure,
  }
}
