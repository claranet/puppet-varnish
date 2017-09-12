# Add the Varnish repo
class varnish::repo::redhat {
    include ::packagecloud

    $ver = delete($::varnish::varnish_version,'.')

    ::packagecloud::repo { 'varnish-cache':
      fq_name => "varnishcache/varnish${ver}",
      type    => 'rpm',
    }

}
