# Specify the secret file for varnishadm
# This file can be changed without notifying varnish
class varnish::secret ($secret) {

  if $secret {
    file { $varnish::params::secret_file:
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => "${secret}\n",
    }
  }
  else {
    file { $varnish::params::secret_file:
      owner => 'root',
      group => 'root',
      mode  => '0600',
    }

    exec { 'Generate Varnish secret file':
      unless  => "/bin/egrep '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' '${varnish::params::secret_file}' >/dev/null",
      command => "/bin/cp /proc/sys/kernel/random/uuid '${varnish::params::secret_file}'",
    }
  }
}
