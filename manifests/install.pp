# == Class varnish::install
#
class varnish::install {
  if $varnish::addrepo == true {
    Package[$varnish::package_name] {
      require => $varnish::repo::package_require,
    }
  }

  package { $varnish::package_name:
    ensure  => $varnish::package_ensure,
  }
}
