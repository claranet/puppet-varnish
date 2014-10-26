# == Class: varnish
#
# Full description of class varnish here.
#
# === Parameters
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#
class varnish (
  $addrepo = true,
  $secret = 'notsosecret',
  $secret_file = $varnish::params::secret_file,
  $vcl_conf = $varnish::params::vcl_conf,
  $listen = $varnish::params::listen,
  $listen_port = $varnish::params::listen_port,
  $admin_listen = $varnish::params::admin_listen,
  $admin_port = $varnish::params::admin_port,
  $min_threads = $varnish::params::min_threads,
  $max_threads = $varnish::params::max_threads,
  $thread_timeout = $varnish::params::thread_timeout,
  $storage_type = $varnish::params::storage_type,
  $storage_file = $varnish::params::storage_file,
  $storage_size = $varnish::params::storage_size,
  $varnish_version = $varnish::params::varnish_version,
  $runtime_params = {}
) inherits varnish::params {

  validate_bool($addrepo)
  validate_string($secret)
  validate_absolute_path($secret_file)
  validate_re("$listen_port", '^[0-9]+$')
  validate_re("$admin_port", '^[0-9]+$')
  validate_re("$min_threads", '^[0-9]+$')
  validate_re("$max_threads", '^[0-9]+$')
  validate_absolute_path($storage_file)
  validate_hash($runtime_params)
  validate_re("$varnish_version", '^[3-4]\.0')
  validate_re("$storage_type", '^(malloc|file)$')

  if ($addrepo) {
    class { $varnish::params::repoclass:
      before => Class['varnish::install'],
    }
  }

  class { 'varnish::secret':
    require => Class['varnish::install'],
  }

  class { 'varnish::install': } ->
  class { 'varnish::config': } ~>
  class { 'varnish::service': } ->
  Class['varnish']
}
