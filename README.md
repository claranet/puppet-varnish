# puppet-varnish

[![Build Status](https://secure.travis-ci.org/claranet/puppet-varnish.png?branch=master)](http://travis-ci.org/claranet/puppet-varnish)
[![Puppet Forge](http://img.shields.io/puppetforge/v/claranet/varnish.svg)](https://forge.puppetlabs.com/claranet/varnish)
[![Forge Downloads](https://img.shields.io/puppetforge/dt/claranet/varnish.svg)](https://forge.puppetlabs.com/claranet/varnish)

#### Table of Contents

1. [Overview - What is the puppet-varnish module?](#overview)
1. [Module Description - What does the module do?](#module-description)
1. [Setup - The basics of getting started with puppet-varnish](#setup)
1. [Usage - Configuration options and additional functionality](#usage)
    * [Examples](#examples)
    * [Parameter Reference](#parameter-reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Overview

This module Installs and configures Varnish.

## Puppet 3 Support

**Please note that the master branch of this module does not support Puppet 3!**

On 31st December 2016, support for Puppet 3.x was withdrawn. As such, this
module no longer supports Puppet 3 - if you require Puppet 3 compatibility,
please use the latest version [4.x version from the Puppet Forge](https://forge.puppet.com/Claranet/varnish), or the [puppet3](https://github.com/claranet/varnish/tree/puppet3) branch in Git.

## Module Description

This module Supports Varnish versions 3.0, 4.0, 4.1, 5.0, 5.1, 5.2,
6.0, 6.1, 6.2, 6.3, 6.4, 6.5, 6.6 across Ubuntu 14.04/16.04/18.04,
Debian 7/8/9/10 and RedHat derivates 6/7.

This module will install Varnish, **by default version 4.1** from the official
Packagecloud repositories, adding EPEL for RedHat-like systems and working
around a SELinux policy bug in RHEL/CentOS 6 for Varnish 4.0 and above.

It will also install and configure a Systemd service for certain OS/Varnish
combinations.

If necessary, you can specify any of the Varnish versions above, although there
are imcompatibilities with some versions of Varnish and some OS versions, see
[Limitations](#limitations).

## Setup

To accept all default parameters - at minimum it is suggested you set a
secret (if not explicitly set, one will be created via
`/proc/sys/kernel/random/uuid`) and overwrite the packaged `default.vcl`.

```puppet
  class { '::varnish':
    secret => '6565bd1c-b6d1-4ba3-99bc-3c7a41ffd94f',
  }

  ::varnish::vcl { '/etc/varnish/default.vcl':
    content => template('data/varnish/default.vcl.erb'),
  }
```

### Multiple Listen Interfaces

Varnish supports listening on multiple interfaces. The module implements this
by exposing a `listen` parameter, which can either be set to a String value for
one interface (e.g. `127.0.0.1` or `0.0.0.0`), or an array of values.

By default, the module will append `listen_port` to each element of the
array - however to set a different port for each interface, just append it
using standard notation, for example: `127.0.0.1:8080`.

## Usage

### Examples

To use a static file with `varnish::vcl` rather than a template:

```puppet
  ::varnish::vcl { '/etc/varnish/default.vcl':
   content => file('data/varnish/default.vcl'),
   # Equivalent to: source => 'puppet:///modules/data/varnish/default.vcl'
  }
```

To pin Varnish to a specific version - you may also provide `varnish_version`
as long as it matches the major and minor version in `package_ensure`, however
the module will automatically calculate `varnish_version` if not set:

```puppet
  class { '::varnish':
    package_ensure => '4.0.5-1~xenial',
  }
```

To configure Varnish to listen on port 8080 on localhost and port 6081 on
`172.16.100.10`:

```puppet
  class { '::varnish':
    listen => ['127.0.0.1:8080','172.16.100.10:6081'],
  }
```

To configure Varnish to listen on port 80, specifically on localhost and
`192.168.1.195`:

```puppet
  class { '::varnish':
    listen      => ['127.0.0.1','192.168.1.195'],
    listen_port => '80',
  }
```

To use multiple storage backends in varnish for example a primary `4GB memory backend` and a `50GB file backend`:

```puppet
  class { '::varnish':
    storage_type => 'malloc',
    storage_size => '4G',
    storage_additional => [
      'file,/var/lib/varnish/varnish_additional.bin,50G',

    ]
  }
```

### Parameter Reference

|Parameter|Description|
|---------|-----------|
|addrepo|Whether to add the official Varnish repos|
|varnish_version|Major Varnish version|
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
|storage_additional|Hash of additional storage backends, passed plainly to varnishd -s after the normal configured storage backends|
|package_ensure|Version of Varnish package to install, eg 3.0.5-1.el6|
|runtime_params|hash of run-time parameters to be specified at startup|


## Limitations

There are several limitations with various Varnish and OS combinations. The
module will attempt to flag known issues, however:

* Varnish 3.0 is not supported on Ubuntu 16.04
* Varnish 5.x, 6.x, supports **only** Debian 8 and Ubuntu 16.04

## Development

* Copyright (C) 2017 Claranet
* Distributed under the terms of the Apache License v2.0 - see LICENSE file for details.
