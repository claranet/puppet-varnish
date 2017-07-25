# Add the Varnish repo
class varnish::repo::debian {
    include ::apt

    ::apt::source { 'varnish-cache':
        comment  => "Apt source for Varnish ${::varnish::varnish_version}",
        location => 'http://repo.varnish-cache.org/debian',
        repos    => "varnish-${::varnish::varnish_version}",
        key      => {
          source => 'https://repo.varnish-cache.org/GPG-key.txt',
          id     => 'E98C6BBBA1CBC5C3EB2DF21C60E7C096C4DEFFEB',
        },
    }

    exec { 'varnish-cache apt-update':
      command => 'apt-get update',
      refreshonly => true,
      subscribe   => Apt::Source['varnish-cache'],
      path        => '/usr/bin:/usr/sbin',
    }
}
