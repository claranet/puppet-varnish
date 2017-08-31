# Add the Varnish repo
class varnish::repo::redhat {
    include ::packagecloud

    $version = "${::varnish::varnish_version}"

    $ver = inline_template('<%= @version.sub(".","") %>')

    ::packagecloud::repo { "varnish-cache":
      fq_name => "varnishcache/varnish$ver",
      type => 'rpm',
    }

}
