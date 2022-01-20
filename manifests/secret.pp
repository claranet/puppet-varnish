# Specify the secret file for varnishadm
# This file can be changed without notifying varnish
class varnish::secret (
  Optional[String] $secret = undef,
) {
  if $secret {
    file { $varnish::secret_file:
      owner   => 'root',
      group   => 'varnish',
      mode    => '0640',
      content => "${secret}\n",
    }
  } else {
    file { $varnish::secret_file:
      owner => 'root',
      group => 'varnish',
      mode  => '0640',
    }

    exec { 'Generate Varnish secret file':
      unless  => "/bin/egrep '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' '${varnish::secret_file}' >/dev/null",
      command => "/bin/cp /proc/sys/kernel/random/uuid '${varnish::secret_file}'",
    }
  }
}
