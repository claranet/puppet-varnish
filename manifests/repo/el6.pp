# Add the Varnish repo
class varnish::repo::el6 {
  yumrepo { 'varnish-cache':
    baseurl  => "https://repo.varnish-cache.org/redhat/varnish-${::varnish::varnish_version}/el6/",
    descr    => 'Varnish-cache RPM repository',
    enabled  => 1,
    gpgcheck => 0
  }
}
