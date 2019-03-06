require 'spec_helper'

describe 'varnish', type: :class do
  ['3.0', '4.0', '4.1', '5.0', '5.1', '5.2', '6.0', '6.0lts', '6.1'].each do |version|
    on_supported_os.each do |os, facts|
      context "Varnish #{version} on #{os}" do
        let(:facts) do
          facts.merge(path: '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/snap/bin:/opt/puppetlabs/bin')
        end

        let(:params) do
          {
            varnish_version: version,
          }
        end

        should_fail = 0
        case version
        when '3.0'
          if facts[:operatingsystem] == 'Ubuntu' && Gem::Version.new(facts[:operatingsystemmajrelease]) >= Gem::Version.new('16.04')
            it { is_expected.to raise_error(Puppet::Error, %r{Varnish 3 from Packagecloud is not supported after Ubuntu 14.04 \(Trusty\)}) }
            should_fail = 1
          end
        when '5.0'
          if facts[:osfamily] == 'RedHat'
            case facts[:operatingsystemmajrelease]
            when '6'
              it { is_expected.to raise_error(Puppet::Error, %r{Varnish 5.0 from Packagecloud is not supported on RHEL\/CentOS 6}) }
              should_fail = 1
            when '7'
              # rubocop:disable LineLength
              it { is_expected.to raise_error(Puppet::Error, %r{Varnish 5.0 on RHEL\/CentOS 7 has a known packaging bug in the varnish_reload_vcl script, please use 5.1 instead. If the bug has been fixed, please submit a pull request to remove this message.}) }
              # rubocop:enable LineLength
              should_fail = 1
            end
          elsif facts[:osfamily] == 'Debian'
            case facts[:lsbdistcodename]
            when 'wheezy'
              it { is_expected.to raise_error(Puppet::Error, %r{Varnish 5.0 from Packagecloud is not supported on Debian 7 \(Wheezy\)}) }
              should_fail = 1
            when 'trusty'
              # rubocop:disable LineLength
              it { is_expected.to raise_error(Puppet::Error, %r{Varnish 5.0 has a known packaging bug in the reload-vcl script, please use 5.1 instead. If the bug has been fixed, please submit a pull request to remove this message.}) }
              # rubocop:enable LineLength
              should_fail = 1
            end
          end
        when /6/
          if facts[:osfamily] == 'RedHat'
            if facts[:operatingsystemmajrelease] == '6'
              it { is_expected.to raise_error(Puppet::Error, %r{Varnish 6.0 and above from Packagecloud is not supported on RHEL\/CentOS 6}) }
              should_fail = 1
            end
          elsif facts[:osfamily] == 'Debian'
            if facts[:operatingsystem] == 'Debian' && facts[:lsbdistcodename] != 'stretch'
              it { is_expected.to raise_error(Puppet::Error, %r{Varnish 6.0 and above is only supported on Debian 9 \(Stretch\)}) }
              should_fail = 1
            end

            if facts[:operatingsystem] == 'Ubuntu' && Gem::Version.new(facts[:operatingsystemmajrelease]) < Gem::Version.new('16.04')
              it { is_expected.to raise_error(Puppet::Error, %r{Varnish 6.0 and above is only supported on Ubuntu 16.04 \(Xenial\) and newer}) }
              should_fail = 1
            end
          end
        end

        if should_fail == 0
          it { is_expected.to compile.with_all_deps }

          if (facts[:osfamily] == 'RedHat' && facts[:operatingsystemmajrelease] == '7' && version != '3.0') ||
             (facts[:osfamily] == 'Debian' && (facts[:lsbdistcodename] == 'jessie' || facts[:lsbdistcodename] == 'xenial'))
            it { is_expected.to contain_file('/etc/systemd/system/varnish.service') }
            it { is_expected.to contain_exec('varnish_systemctl_daemon_reload') }
          end

          case facts[:osfamily]
          when 'RedHat'

            if facts[:operatingsystemmajrelease] == '6' && version != '3.0'
              it { is_expected.to contain_selinux__module('varnishpol') }
            end

            it { is_expected.to contain_file('/etc/sysconfig/varnish') }
            it { is_expected.to contain_yumrepo('varnish-cache') }
            it { is_expected.to contain_yumrepo('varnish-cache-source') }
          when 'Debian'
            it { is_expected.to contain_file('/etc/default/varnish') }
            it { is_expected.to contain_package('apt-transport-https') }
            it { is_expected.to contain_apt__source('varnish-cache') }
          end

        end
      end
    end
  end

  context 'supported operating systems' do
    let(:facts) do
      {
        osfamily: 'RedHat',
        operatingsystem: 'CentOS',
        operatingsystemmajrelease: '7',
        path: '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/snap/bin:/opt/puppetlabs/bin',
        lsbdistrelease: nil,
      }
    end

    it { is_expected.to contain_class('varnish::params') }
    it { is_expected.to contain_class('varnish::repo').that_comes_before('Class[varnish::install]') }
    it { is_expected.to contain_class('varnish::install').that_comes_before('Class[varnish::secret]') }
    it { is_expected.to contain_class('varnish::secret').that_comes_before('Class[varnish::config]') }
    it { is_expected.to contain_class('varnish::config').that_notifies('Class[varnish::service]') }
    it { is_expected.to contain_class('varnish::config').that_comes_before('Class[varnish::service]') }
    it { is_expected.to contain_class('varnish::service') }

    it { is_expected.to contain_file('/etc/varnish/secret') }
    it { is_expected.to contain_exec('Generate Varnish secret file') }
    it { is_expected.to contain_package('varnish') }
    it { is_expected.to contain_service('varnish') }
    it { is_expected.to contain_exec('vcl_reload') }
  end

  context 'unsupported operating systems' do
    describe 'varnish class fail on unsupported OS' do
      let(:facts) do
        {
          osfamily: 'Darwin',
          operatingsystem: 'Darwin',
          path: '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/snap/bin:/opt/puppetlabs/bin',
          lsbdistrelease: nil,
        }
      end

      it { is_expected.to raise_error(Puppet::Error, %r{Darwin not supported}) }
    end
  end
end
