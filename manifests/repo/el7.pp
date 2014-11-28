# Add the Varnish repo
class varnish::repo::el7 {
  yumrepo { 'varnish-cache':
    baseurl  => "https://repo.varnish-cache.org/redhat/varnish-${::varnish::varnish_version}/el7/",
    descr    => 'Varnish-cache RPM repository',
    enabled  => 1,
    gpgcheck => 0
  }
}
