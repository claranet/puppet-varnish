# Add the Varnish repo
class varnish::repo::debian {
    include ::apt

    $ver_num = delete($::varnish::varnish_version,'.')
    $os_lower = downcase($facts['os']['name'])

    ensure_packages('apt-transport-https')

    case $::varnish::varnish_version {
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
        fail("Unsupported Varnish repo version: ${::varnish::varnish_version}")
      }
    }

    ::apt::source { 'varnish-cache':
        comment  => "Apt source for Varnish ${::varnish::varnish_version}",
        location => "https://packagecloud.io/varnishcache/varnish${ver_num}/${os_lower}/",
        repos    => 'main',
        require  => Package['apt-transport-https'],
        key      => {
          source => "https://packagecloud.io/varnishcache/varnish${ver_num}/gpgkey",
          id     => $gpg_key_id,
        },
        include  => {
          'deb' => true,
          'src' => true,
        },
    }
}
