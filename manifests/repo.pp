# Add the Varnish repo
class varnish::repo {
  $ver = "${varnish::version_major}${varnish::version_minor}${varnish::version_lts}"

  case $facts['os']['family'] {
    'RedHat': {
      if $ver == '50' {
        if $facts['os']['release']['major'] == '6' {
          fail('Varnish 5.0 from Packagecloud is not supported on RHEL/CentOS 6')
        } elsif $facts['os']['release']['major'] == '7' {
          # https://github.com/varnishcache/pkg-varnish-cache/issues/42
          fail('Varnish 5.0 on RHEL/CentOS 7 has a known packaging bug in the varnish_reload_vcl script, please use 5.1 instead. If the bug has been fixed, please submit a pull request to remove this message.')
        }
      }

      if $varnish::version_major == '6' and $facts['os']['release']['major'] == '6' {
        fail('Varnish 6.0 and above from Packagecloud is not supported on RHEL/CentOS 6')
      }

      $package_require = undef

      # Varnish 4 and above need EPEL for jemalloc
      if $varnish::version_major != '3' {
        include epel
        Yumrepo['varnish-cache','varnish-cache-source'] {
          require => Yumrepo['epel'],
        }
      }

      yumrepo { 'varnish-cache':
        descr           => "varnishcache_varnish${ver}",
        baseurl         => "https://packagecloud.io/varnishcache/varnish${ver}/el/${facts['os']['release']['major']}/\$basearch",
        gpgkey          => "https://packagecloud.io/varnishcache/varnish${ver}/gpgkey",
        metadata_expire => '300',
        repo_gpgcheck   => '1',
        gpgcheck        => '0',
        sslverify       => '1',
        sslcacert       => '/etc/pki/tls/certs/ca-bundle.crt',
      }

      yumrepo { 'varnish-cache-source':
        descr           => "varnishcache_varnish${ver}-source",
        baseurl         => "https://packagecloud.io/varnishcache/varnish${ver}/el/${facts['os']['release']['major']}/SRPMS",
        gpgkey          => "https://packagecloud.io/varnishcache/varnish${ver}/gpgkey",
        metadata_expire => '300',
        repo_gpgcheck   => '1',
        gpgcheck        => '0',
        sslverify       => '1',
        sslcacert       => '/etc/pki/tls/certs/ca-bundle.crt',
      }
    }

    'Debian': {
      case $facts['os']['name'] {
        'Debian': {
          if $ver == '50' and $facts['os']['distro']['codename'] == 'wheezy' {
            fail('Varnish 5.0 from Packagecloud is not supported on Debian 7 (Wheezy)')
          }

          if $varnish::version_major == '6' and versioncmp($facts['os']['release']['full'],'9.0') == -1 {
            fail('Varnish 6.0 and above is only supported on Debian 9 (Stretch) and above')
          }
        }

        'Ubuntu': {
          if $ver == '30' and versioncmp($facts['os']['release']['full'], '16.04') >= 0 {
            fail('Varnish 3 from Packagecloud is not supported after Ubuntu 14.04 (Trusty)')
          }

          if $ver == '50' and $facts['os']['distro']['codename'] == 'trusty' {
            fail('Varnish 5.0 has a known packaging bug in the reload-vcl script, please use 5.1 instead. If the bug has been fixed, please submit a pull request to remove this message.')
          }

          if $varnish::version_major == '6' and versioncmp($facts['os']['release']['full'], '16.04') == -1 {
            fail('Varnish 6.0 and above is only supported on Ubuntu 16.04 (Xenial) and newer')
          }
        }

        default: {
          fail("Unsupported Debian OS: ${facts['os']['name']}")
        }
      }

      ensure_packages('apt-transport-https')

      $os_lower        = downcase($facts['os']['name'])
      $package_require = Exec['apt_update']
      $gpg_key_id      = "${varnish::version_major}.${varnish::version_minor}${varnish::version_lts}" ? {
        '6.1'    => '4A066C99B76A0F55A40E3E1E387EF1F5742D76CC',
        '6.0lts' => '48D81A24CB0456F5D59431D94CFCFD6BA750EDCD',
        '6.0'    => '7C5B46721AF00FD57E68E6E8D2605BF74E8B9DBA',
        '5.2'    => '91CFD5635A1A5FAC0662BEDD2E9BA3FE86BE909D',
        '5.1'    => '54DC32329C37703D8B2819E6414C46826B880524',
        '5.0'    => '1487779B0E6C440214F07945632B6ED0FF6A1C76',
        '4.1'    => '9C96F9CA0DC3F4EA78FF332834BF6E8ECBF5C49E',
        '4.0'    => 'B7B16293AE0CC24216E9A83DD4E49AD8DE3FFEA4',
        '3.0'    => '246BE381150865E2DC8C6B01FC1318ACEE2C594C',
      }

      ::apt::source { 'varnish-cache':
        comment  => "Apt source for Varnish ${varnish::version_major}.${varnish::version_minor}${varnish::version_lts}",
        location => "https://packagecloud.io/varnishcache/varnish${ver}/${os_lower}/",
        repos    => 'main',
        require  => Package['apt-transport-https'],
        key      => {
          source => "https://packagecloud.io/varnishcache/varnish${ver}/gpgkey",
          id     => $gpg_key_id,
        },
        include  => {
          'deb' => true,
          'src' => true,
        },
      }
    }

    default: {
      fail("Unsupported repo osfamily: ${facts['os']['family']}")
    }
  }
}
