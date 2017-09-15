# Add the Varnish repo
class varnish::repo {

    $ver      = "${::varnish::version_major}${::varnish::version_minor}"
    $os_lower = downcase($facts['os']['name'])

    case $::osfamily {
      'RedHat': {

          # Varnish 4 and above need EPEL for jemalloc
          if $::varnish::version_major != '3' {
            include ::epel
            Yumrepo['varnish-cache','varnish-cache-source'] {
              require => Yumrepo['epel'],
            }
          }

          yumrepo { 'varnish-cache':
            descr           => "varnishcache_varnish${ver}",
            baseurl         => "https://packagecloud.io/varnishcache/varnish${ver}/el/${::operatingsystemmajrelease}/\$basearch",
            gpgkey          => "https://packagecloud.io/varnishcache/varnish${ver}/gpgkey",
            metadata_expire => '300',
            repo_gpgcheck   => true,
            gpgcheck        => false,
            sslverify       => true,
            sslcacert       => '/etc/pki/tls/certs/ca-bundle.crt',
          }

          yumrepo { 'varnish-cache-source':
            descr           => "varnishcache_varnish${ver}-source",
            baseurl         => "https://packagecloud.io/varnishcache/varnish${ver}/el/${::operatingsystemmajrelease}/SRPMS",
            gpgkey          => "https://packagecloud.io/varnishcache/varnish${ver}/gpgkey",
            metadata_expire => '300',
            repo_gpgcheck   => true,
            gpgcheck        => false,
            sslverify       => true,
            sslcacert       => '/etc/pki/tls/certs/ca-bundle.crt',
          }
      }

      'Debian': {
        ensure_packages('apt-transport-https')

        case "${::varnish::version_major}.${::varnish::version_minor}" {
           '4.0': {
             $gpg_key_id = 'B7B16293AE0CC24216E9A83DD4E49AD8DE3FFEA4'
           }

           '4.1': {
             $gpg_key_id = '9C96F9CA0DC3F4EA78FF332834BF6E8ECBF5C49E'
           }

           '3.0': {
             $gpg_key_id = '246BE381150865E2DC8C6B01FC1318ACEE2C594C'
           }

           default: {
             fail("Unsupported Varnish repo version: ${::varnish::version_major}.${::varnish::version_minor}")
           }
         }

      }

      default: {
        fail("Unsupported osfamily: ${::osfamily}")
      }
    }

}
