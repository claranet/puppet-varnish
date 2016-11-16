source 'https://rubygems.org'

group :test do
  gem 'rake'
  gem 'puppet-lint'
  gem 'rspec-puppet'
  gem 'rspec-system-puppet'
  gem 'puppetlabs_spec_helper'
  gem 'puppet-syntax'
  gem 'puppet', ENV['PUPPET_VERSION'] || '~> 3.7.0'
  gem 'json_pure', '< 2.0.0'
  gem 'json', '< 2.0.0'
  # https://tickets.puppetlabs.com/browse/PUP-3796
  gem 'safe_yaml', '~> 1.0.4'
end

group :development do
  gem 'travis'
  gem 'travis-lint'
  gem 'vagrant-wrapper'
  gem 'puppet-blacksmith'
end
