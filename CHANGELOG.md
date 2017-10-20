# Change Log

Release notes for the claranet/puppet-varnish module.

------------------------------------------

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
  * Removes old repository and moves to Pacakgecloud
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
