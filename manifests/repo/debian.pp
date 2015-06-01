# Add the Varnish repo
class varnish::repo::debian {
    include apt
    
    apt::source { 'varnish-cache':
        comment  => 'Apt source for Varnish 4',
        location => 'http://repo.varnish-cache.org/debian',
        repos    => 'varnish-4.0',
        key      => 'E98C6BBBA1CBC5C3EB2DF21C60E7C096C4DEFFEB'
    }
}