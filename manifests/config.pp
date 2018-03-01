# == Class varnish::config
#
# This class is called from varnish
#
class varnish::config {

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
        before    => Service[$::varnish::service_name],
        notify    => Service[$::varnish::service_name],
      }
    }
  }

  file { $::varnish::params::sysconfig:
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('varnish/sysconfig.erb'),
  }


  if $::varnish::params::service_provider == 'systemd' {

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
