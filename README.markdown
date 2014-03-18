#varnish

[![Build
Status](https://travis-ci.org/BashtonLtd/puppet-varnish.png?branch=master)](https://travis-ci.org/BashtonLtd/puppet-varnish)

Installs and configures Varnish.  Requires you to have a VCL specified
in a parameter.

Currently only working on EL6 derived distros (RHEL6, CentOS 6, OEL 6,
Amazon Linux)

Requires Puppet >= 3.0

## Basic Usage

```puppet

  class { 'varnish':
    secret => '6565bd1c-b6d1-4ba3-99bc-3c7a41ffd94f',
  }

  varnish::vcl { '/etc/varnish/default.vcl':
    content => template('data/varnish/default.vcl.erb'),
  }
```

### Parameters

All parameters are optional, but at minimum it is suggested you set a
secret.

|Parameter|Description|
|---------|-----------|
|addrepo|Whether to add the official Varnish repos|
|secret|Secret for admin access|
|secret_file|File to store the secret|
|vcl_conf|Varnish vcl config file path|
|listen|IP to bind to|
|listen_port|TCP port to listen on|
|admin_listen|Admin IP to bind to|
|admin_port|TCP port for admin to listen on|
|min_threads|Minimum Varnish worker threads|
|max_threads|Maximum Varnish worker threads|
|thread_timeout|Terminate threads after this long idle|
|storage_file|File to mmap on disk for cache storage|
|storage_size|Size of storage file, eg 10G or 50%|
|runtime_params|hash of run-time parameters to be specified at startup|
