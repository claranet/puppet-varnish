# puppet-varnish

[![Build Status](https://secure.travis-ci.org/claranet/puppet-varnish.png?branch=master)](http://travis-ci.org/claranet/puppet-varnish)

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

## Module Description

This module Supports Varnish versions 3.0, 4.0, 4.1, 5.0, 5.1 and 5.2 across
Ubuntu 14.04/16.04, Debian 7/8 and RedHat derivates 6/7.

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
|package_ensure|Version of Varnish package to install, eg 3.0.5-1.el6|
|runtime_params|hash of run-time parameters to be specified at startup|


## Limitations

There are several limitations with various Varnish and OS combinations. The
module will attempt to flag known issues, however:

* Varnish 3.0 is not supported on Ubuntu 16.04
* Varnish 5.0 supports **only** Debian 8 and Ubuntu 16.04

## Development

* Copyright (C) 2017 Claranet
* Distributed under the terms of the Apache License v2.0 - see LICENSE file for details.
