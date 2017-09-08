# Add the Varnish repo
class varnish::repo::debian {
    include ::packagecloud

    $ver = delete($::varnish::varnish_version,'.')

    ::packagecloud::repo { 'varnish-cache':
      fq_name => "varnishcache/varnish${ver}",
      type    => 'deb',
    }

    exec { 'varnish-cache apt-update':
      command     => 'apt-get update',
      refreshonly => true,
      subscribe   => Packagecloud::Repo['varnish-cache'],
      path        => '/usr/bin:/usr/sbin',
    }
}
