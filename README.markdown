#varnish


[![build
Status](https://travis-ci.org/BashtonLtd/puppet-varnish.png?branch=master)](https://travis-ci.org/BashtonLtd/puppet-varnish)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with Varnish](#setup)
    * [Beginning with Varnish](#beginning-with-varnish])
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Installs and configures Varnish.  Requires you to have a VCL specified
in a parameter.

## Module Description

Supports:
 * Varnish 3 and 4 on EL6 and derivatives (RHEL, CentOS, OEL, Amazon Linux)
 * Varnish 3 on Ubuntu 12.04
 * Varnish 3 on Debian 7
 * Varnish 4 on EL7 and derivatives
 * Varnish 4 on Ubuntu 14.04
 * Varnish 4 on Debian 7 and 8

Requires Puppet >= 3.0

## Setup

This module will install Varnish, by default from the official Varnish
repos.

### Beginning with Varnish

```puppet

  class { 'varnish':
    secret => '6565bd1c-b6d1-4ba3-99bc-3c7a41ffd94f',
  }

  varnish::vcl { '/etc/varnish/default.vcl':
    content => template('data/varnish/default.vcl.erb'),
  }
```

### Usage

All parameters are optional, but at minimum it is suggested you set a
secret.

|Parameter|Description|
|---------|-----------|
|addrepo|Whether to add the official Varnish repos|
|varnish_version|Major Varnish version - should be 3.0 or 4.0|
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
|storage_type|malloc or file|
|storage_file|File to mmap on disk for cache storage|
|storage_size|Size of storage file or RAM, eg 10G or 50%|
|package_ensure|Version of Varnish package to install, eg 3.0.5-1.el6|
|runtime_params|hash of run-time parameters to be specified at startup|


## Limitations

## Development

Before making any changes, please run `bundle install` and then `bundle
exec rake test` to ensure all tests pass.

Once you have completed your change, run `bundle exec rake test` to run
the tests again and ensure you haven't broken any existing
functionality.  If you've added new functionality, please add tests for
this.

We try extremely hard not to break existing functionality, and so pull
requests which do so are unlikely to be accepted.
