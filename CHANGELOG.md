# Change Log

Release notes for the claranet/puppet-varnish module.

------------------------------------------

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
