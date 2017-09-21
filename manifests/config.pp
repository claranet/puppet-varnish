# == Class varnish::config
#
# This class is called from varnish
#
class varnish::config {

  # This needs to be here because it depends on Varnish version, which isn't
  # available to params.pp - open to suggestions of nicer ways of doing this!

  if $::varnish::version_major == '3' {
    if $::operatingsystem == 'Debian' {
      if versioncmp($::lsbdistrelease,'8.0') >= 1 {
        $_service_provider = 'systemd'
      } else {
        $_service_provider = 'sysvinit'
      }
    } else {
      $_service_provider = 'sysvinit'
    }
  } else {
    $_service_provider = $::varnish::params::service_provider
  }

  if versioncmp("${::varnish::version_major}.${::varnish::version_minor}",'4.1') >= 0 {
    $jail_opt = '-j unix,user=varnish,ccgroup=varnish'
  } else {
    $jail_opt = '-u varnish -g varnish'
  }

  # Deploy Varnish 4+ SELinux hack on RHEL6
  if $::osfamily == 'RedHat' and $::operatingsystemmajrelease == '6' and $::varnish::version_major != '3' {
    if $::selinux_current_mode == 'enforcing' {
      ::selinux::module { 'varnishpol':
        ensure    => present,
        source_te => 'puppet:///modules/varnish/varnishpol.te',
        builder   => 'simple',
        before    => Service[$::varnish::service_name],
        notify    => Service[$::varnish::service_name],
      }
    }
  }

  if $_service_provider == 'sysvinit' {
    file { $::varnish::params::sysconfig:
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('varnish/sysconfig.erb'),
    }
  } else {

    file { '/etc/systemd/system/varnish.service':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('varnish/varnish.service.erb'),
      notify  => Exec['varnish_systemctl_daemon_reload'],
    }

    exec { 'varnish_systemctl_daemon_reload':
      command     => '/bin/systemctl daemon-reload',
      refreshonly => true,
      require     => File['/etc/systemd/system/varnish.service'],
      notify      => Service[$::varnish::service_name],
    }
  }

}
