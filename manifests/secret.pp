# Specify the secret file for varnishadm
# This file can be changed without notifying varnish
class varnish::secret {

  file { $varnish::params::secret_file:
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => "${varnish::params::secret}\n",
  }

}
