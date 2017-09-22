require 'spec_helper'

describe 'varnish', :type => :class do

  ['3.0', '4.0', '4.1', '5.0', '5.1', '5.2'].each do |version|

    on_supported_os.each do |os, facts|
      context "Varnish #{version} on #{os}" do

        let(:facts) do
          facts.merge({
            :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/snap/bin:/opt/puppetlabs/bin',
          })
        end

        let (:params) {{
          :varnish_version => version,
          :addrepo         => true
        }}

        should_fail = 0
        case version
        when '3.0'
          if facts[:lsbdistcodename] == 'xenial'
            it { is_expected.to raise_error(Puppet::Error, /Varnish 3 from Packagecloud is not supported on Ubuntu 16.04 \(Xenial\)/) }
            should_fail = 1
          end
        when '5.0'
          if facts[:osfamily] == 'RedHat'
            case facts[:operatingsystemmajrelease]
            when '6'
              it { is_expected.to raise_error(Puppet::Error, /Varnish 5.0 from Packagecloud is not supported on RHEL\/CentOS 6/) }
              should_fail = 1
            when '7'
              it { is_expected.to raise_error(Puppet::Error, /Varnish 5.0 on RHEL\/CentOS 7 has a known packaging bug in the varnish_reload_vcl script, please use 5.1 instead. If the bug has been fixed, please submit a pull request to remove this message./) }
              should_fail = 1
            end
          elsif facts[:osfamily] == 'Debian'
            case facts[:lsbdistcodename]
            when 'wheezy'
              it { is_expected.to raise_error(Puppet::Error, /Varnish 5.0 from Packagecloud is not supported on Debian 7 \(Wheezy\)/) }
              should_fail = 1
            when 'trusty'
              it { is_expected.to raise_error(Puppet::Error, /Varnish 5.0 has a known packaging bug in the reload-vcl script, please use 5.1 instead. If the bug has been fixed, please submit a pull request to remove this message./) }
              should_fail = 1
            end
          end
        end

        if should_fail == 0
          it { should compile.with_all_deps }
          it { is_expected.to contain_class('varnish::params') }
          it { is_expected.to contain_class('varnish::repo').that_comes_before('Class[varnish::install]') }
          it { is_expected.to contain_class('varnish::install').that_comes_before('Class[varnish::secret]') }
          it { is_expected.to contain_class('varnish::secret').that_comes_before('Class[varnish::config]') }
          it { is_expected.to contain_class('varnish::config').that_notifies('Class[varnish::service]') }
          it { is_expected.to contain_class('varnish::config').that_comes_before('Class[varnish::service]') }
          it { is_expected.to contain_class('varnish::service') }
        end
      end
    end
  end

  context 'supported operating systems' do
    on_supported_os.each do |os, facts|

      context "on #{os}" do
        let(:facts) do
          facts.merge({
            'kernel'           => 'Linux',
            'staging_http_get' => 'curl',
            'concat_basedir'   => '/var/lib/puppet/concat'
          })
        end
      end
    end
  end

  context 'unsupported operating systems' do

    describe "varnish class fail on unsupported OS" do
      let(:facts) {{
        :osfamily        => 'Darwin',
        :operatingsystem => 'Darwin',
        :path            => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/snap/bin:/opt/puppetlabs/bin',
        :lsbdistrelease  => nil
      }}

      it { is_expected.to raise_error(Puppet::Error, /Darwin not supported/) }
    end
  end
end
