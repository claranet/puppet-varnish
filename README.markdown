#varnish

Installs and configures Varnish.  Requires you to have a VCL specified
in a parameter.

Currently only working on EL6 derived distros (RHEL6, CentOS 6, OEL 6,
Amazon Linux)

## Basic Usage

```puppet

  class { 'varnish':
    secret => '6565bd1c-b6d1-4ba3-99bc-3c7a41ffd94f',
  }

  varnish::vcl { '/etc/varnish/default.vcl':
    content => template('data/varnish/default.vcl.erb'),
  }
```
