require 'spec_helper'

describe 'varnish', :type => :class do
  context 'supported operating systems' do

    describe "varnish class fail on unsupported OS" do
      let(:facts) {{
        :osfamily        => 'Darwin',
        :operatingsystem => 'Darwin'
      }}

      it { is_expected.to raise_error(Puppet::Error, /Darwin not supported/) }
    end

    describe "varnish class fail on unsupported Debian OS" do
      let(:facts) {{
        :osfamily           => 'Debian',
        :operatingsystem    => 'Ubuntu',
        :lsbdistcodename    => 'zesty',
        :lsbdistdescription => 'Ubuntu 17.04'
      }}

      it { is_expected.to raise_error(Puppet::Error, /Ubuntu \(Ubuntu 17.04, zesty\) not supported/) }
    end

    describe "varnish with generated secret" do

      let(:facts) {{
        :osfamily           => 'Debian',
        :operatingsystem    => 'Ubuntu',
        :lsbdistcodename    => 'precise',
      }}

      it { should compile.with_all_deps }
      it { should contain_class('varnish::params') }
      it { should contain_class('varnish::secret') }
      it { should contain_class('varnish::install').that_comes_before('Class[varnish::config]') }
      it { should contain_class('varnish::config') }
      it { should contain_file('/etc/varnish/secret') }
      it { should contain_exec('Generate Varnish secret file').with_command("/bin/cp /proc/sys/kernel/random/uuid '/etc/varnish/secret'") }
      it { should contain_class('varnish::service').that_subscribes_to('Class[varnish::config]') }

      it { should contain_package('varnish') }
      it { should contain_service('varnish') }
    end

    describe "varnish with hardcoded secret" do

      let(:params) {{
        :secret => 'foobar',
      }}

      let(:facts) {{
        :osfamily           => 'Debian',
        :operatingsystem    => 'Ubuntu',
        :lsbdistcodename    => 'precise',
      }}

      it { should compile.with_all_deps }
      it { should contain_file('/etc/varnish/secret').with_content("foobar\n") }
    end

    on_supported_os.each do |os, facts|

      context "on #{os}" do
        let(:facts) do
          facts.merge({
            :kernel => 'Linux',
          })
        end

        describe "varnish class" do
          it { should compile.with_all_deps }

          case facts[:osfamily]
          when 'RedHat'

            case facts[:operatingsystemmajrelease]
            when '6'
              it { should contain_file('/etc/sysconfig/varnish') }
              it { should contain_class('varnish::repo::el6').that_comes_before('Class[varnish::install]') }
              it { should contain_yumrepo('varnish-cache').with_baseurl('https://repo.varnish-cache.org/redhat/varnish-3.0/el6/') }
              it { should contain_exec('vcl_reload').with_command('/usr/bin/varnish_reload_vcl') }
            when '7'
              it { should contain_file('/etc/varnish/varnish.params') }
              it { should contain_class('varnish::repo::el7').that_comes_before('Class[varnish::install]') }
              it { should contain_yumrepo('varnish-cache').with_baseurl('https://repo.varnish-cache.org/redhat/varnish-4.0/el7/') }
              it { should contain_exec('vcl_reload').with_command('/usr/sbin/varnish_reload_vcl') }
            else
              # Amazon Linux
              it { should contain_file('/etc/sysconfig/varnish') }
              it { should contain_class('varnish::repo::el6').that_comes_before('Class[varnish::install]') }
              it { should contain_yumrepo('varnish-cache').with_baseurl('https://repo.varnish-cache.org/redhat/varnish-3.0/el6/') }
              it { should contain_exec('vcl_reload').with_command('/usr/sbin/varnish_reload_vcl') }
            end

          when 'Debian'

            case facts[:lsbdistcodename]

            when 'precise'
              it { should_not contain_class('varnish::repo::debian').that_comes_before('Class[varnish::install]') }
            else
              it { should contain_class('varnish::repo::debian').that_comes_before('Class[varnish::install]') }
              it { should contain_apt__source('varnish-cache') }
            end

            it { should contain_file('/etc/default/varnish') }
            it { should contain_exec('vcl_reload').with_command('/usr/share/varnish/reload-vcl') }

          end
        end
      end
    end
  end
end
