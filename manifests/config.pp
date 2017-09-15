# == Class varnish::config
#
# This class is called from varnish
#
class varnish::config {

  case $::osfamily {
    'RedHat', 'Amazon': {

      $sysconfig_template = "varnish/el${::operatingsystemmajrelease}/varnish${::varnish::version_major}.sysconfig.erb"

      # Very, very dirty hack inspired by this workaround for Varnish > 3
      # http://flatlinesecurity.com/posts/varnish-4-selinux/
      if $::operatingsystemmajrelease == '6' and $::varnish::version_major != '3' {
        ensure_packages('policycoreutils-python')
        exec { 'varnish_fix_selinux_on_rhel6':
          command => "/sbin/service ${::varnish::params::service_name} start; grep varnishd /var/log/audit/audit.log | audit2allow -M varnishpol; semodule -i varnishpol.pp; rm -f varnishpol.te varnishpol.pp",
          onlyif  => '/usr/sbin/getenforce | grep -q Enforcing',
          creates => '/etc/selinux/targeted/modules/active/modules/varnishpol.pp',
          require => [Package['policycoreutils-python'],File[$::varnish::params::sysconfig]],
          before  => Service[$::varnish::params::service_name],
        }
      }
    }

    'Debian': {
      $sysconfig_template = "varnish/debian/varnish${::varnish::version_major}.default.erb"
    }

    default: {
      fail("Varnish version ${::varnish::version_major}.${::varnish::version_minor} not supported on ${::osfamily}")
    }
  }

  file { $::varnish::params::sysconfig:
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template($sysconfig_template),
  }

}
