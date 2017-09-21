# Add the Varnish repo
class varnish::repo::redhat {

    $ver = delete($::varnish::varnish_version,'.')

    yumrepo { "varnish-cache-${ver}":
      baseurl  => "https://packagecloud.io/varnishcache/varnish${ver}/el/\$releasever/\$basearch",
      descr    => 'The varnish-cache repository',
      enabled  => '1',
      gpgcheck => '0',
      gpgkey   => "https://packagecloud.io/varnishcache/varnish${ver}/gpgkey",
    }

}
