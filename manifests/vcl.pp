# Define a VCL from a Puppet template
# and load the VCL
#
# If the VCL fails to parse, the exec will fail
# and Varnish will continue to run with the old config
define varnish::vcl (
  $content,
  $file = $name) {

  include varnish
  include varnish::params

  file { $file:
    content => $content,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Class['varnish::install'],
    notify  => Exec['vcl_reload'],
  }
}
