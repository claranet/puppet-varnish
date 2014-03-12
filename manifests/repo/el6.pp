# Add the Varnish repo
class varnish::repo::el6 {
  yumrepo { 'varnish-cache':
    baseurl  => 'http://repo.varnish-cache.org/redhat/varnish-3.0/el6/',
    descr    => 'Varnish-cache RPM repository',
    enabled  => 1,
    gpgcheck => 0
  }
}
