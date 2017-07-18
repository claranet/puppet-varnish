# Add the Varnish repo
class varnish::repo::debian {
    include ::apt

    ::apt::source { 'varnish-cache':
        comment  => 'Apt source for Varnish 4',
        location => 'http://repo.varnish-cache.org/debian',
        repos    => "varnish-${::varnish::varnish_version}",
        key      => {
          source => 'https://repo.varnish-cache.org/GPG-key.txt',
          id     => 'E98C6BBBA1CBC5C3EB2DF21C60E7C096C4DEFFEB',
        },
    }
}
