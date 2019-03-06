# Change Log

Release notes for the claranet/puppet-varnish module.

------------------------------------------
## Unreleased
  * Set permissions for `/etc/varnish/secret` to prevent varnish-agent startup issues as described [here](https://github.com/varnish/vagent2/issues/191)

## 5.0.1 - 2018-08-30

### PDK Support
  * This module is now compatible with the Puppet Development Kit - this can be verified by running `pdk validate`

## 5.0.0 - 2018-03-20

### Breaking/Backwards-Incompatible Changes - Puppet 4 Syntax
  * Parameters are validated against Puppet 4 data types
  * Stdlib version requirements have been raised

## 4.2.0 - 2018-02-26
  * New parameter: `varnish::storage_additional` - allows setting multiple storage backends, pull request [#52](https://github.com/claranet/puppet-varnish/issues/52)
  * Adding deprecation notices for Puppet 3

## 4.1.6 - 2017-12-13
  * Fixing version-comparison bug for Debian 8.0

## 4.1.5 - 2017-11-03
  * Adding fully-qualified paths to `varnish_reload_vcl` for all Varnish versions in CentOS 6 and 7

## 4.1.4 - 2017-10-20
  * Fixing Puppet 3 bug in handling of `undef` values of `varnish::instance_name` in ERB templates

## 4.1.3 - 2017-10-17
  * Fixing other syntax errors, pull requests [#45](https://github.com/claranet/puppet-varnish/issues/45) and [#46](https://github.com/claranet/puppet-varnish/issues/46)

## 4.1.2 - 2017-10-12
  * Fixing syntax error in previous release

## 4.1.1 - 2017-10-12
  * Varnish 4+ requires passing multiple listen interfaces by specifying multiple `-a` flags, not a single comma-separated value.
  * Various Puppet 3 fixes

## 4.1.0 - 2017-10-10
  * New parameter: `varnish::instance_name` - allows setting Varnish's instance name - fixes [#44](https://github.com/claranet/puppet-varnish/issues/44)
  * Parameter `listen` now accepts an array to set multiple listen interfaces - fixes [#33](https://github.com/claranet/puppet-varnish/issues/33)

## 4.0.0 - 2017-10-04
  * Major version increase after module move to Claranet GitHub org
  * Adds Varnish 5 support (5.0, 5.1 and 5.2)
  * Removes old repository and moves to PackageCloud
  * Default Varnish version changed to 4.1 for all OS families
  * Systemd service set up depending on Varnish/OS version

## 3.0.0 - 2015-07-20
  * Add support for Debian Wheezy + Jessie
  * Fix Varnish vcl_reload command

## 2.4.1 - 2015-06-25
  * Relax puppetlabs-apt version dependency because of librarian issues

## 2.4.0 - 2015-06-12
  * Added support for Ubuntu 14.04
  * Passing secret is now optional (but still supported)

## 2.3.0 - 2015-04-13
  * Added support for Ubuntu 12.04
  * Improved tests for Varnish 4 on EL6
