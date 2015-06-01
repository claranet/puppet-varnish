require 'spec_helper'

describe 'varnish' do
  context 'supported operating systems' do
    describe "varnish class with minimal parameters on RedHat 6" do
      let(:params) {{
        :secret => 'foobar'
      }}
      let(:facts) {{
        :osfamily                  => 'RedHat',
        :operatingsystemmajrelease => '6',
      }}

      it { should compile.with_all_deps }

      it { should contain_class('varnish::params') }

      it { should contain_class('varnish::repo::el6').that_comes_before('varnish::install') }
      it { should contain_class('varnish::secret') }
      it { should contain_class('varnish::install').that_comes_before('varnish::config') }
      it { should contain_class('varnish::config') }
      it { should contain_class('varnish::service').that_subscribes_to('varnish::config') }

      it { should contain_package('varnish') }
      it { should contain_file('/etc/varnish/secret') \
        .with_content("foobar\n") }
      it { should contain_file('/etc/sysconfig/varnish') }
      it { should contain_service('varnish') }
    end
    describe "varnish class with minimal parameters on RedHat 7" do
      let(:params) {{
        :secret => 'foobar'
      }}
      let(:facts) {{
        :osfamily                  => 'RedHat',
        :operatingsystemmajrelease => '7',
      }}

      it { should compile.with_all_deps }
      it { should contain_yumrepo('varnish-cache') \
        .with_baseurl(/4\.0/) }
      it { should contain_class('varnish::repo::el7').that_comes_before('varnish::install') }
      it { should contain_class('varnish::secret') }
      it { should contain_class('varnish::install').that_comes_before('varnish::config') }
      it { should contain_class('varnish::config') }
      it { should contain_class('varnish::service').that_subscribes_to('varnish::config') }

    end
    describe "varnish class with minimal parameters on Ubuntu 12.04" do
      let(:params) {{
        :secret => 'foobar'
      }}
      let (:facts) {{
        :osfamily        => 'Debian',
        :lsbdistcodename => 'precise',
      }}

      it { should compile.with_all_deps }
      it { should contain_class('varnish::secret') }
      it { should contain_class('varnish::install').that_comes_before('varnish::config') }
      it { should contain_class('varnish::config') }
      it { should contain_class('varnish::service').that_subscribes_to('varnish::config') }

    end

    describe "varnish class with minimal parameters on Ubuntu 14.04" do
      let(:params) {{
        :secret => 'foobar'
      }}
      let (:facts) {{
        :osfamily        => 'Debian',
        # apt looks for lsbdistid
        :lsbdistid       => 'Debian',
        :lsbdistcodename => 'trusty',
      }}

      it { should compile.with_all_deps }
      it { should contain_class('varnish::secret') }
      it { should contain_class('varnish::install').that_comes_before('varnish::config') }
      it { should contain_class('varnish::config') }
      it { should contain_class('varnish::service').that_subscribes_to('varnish::config') }

    end
  end


  context 'unsupported operating system' do
    describe 'varnish class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { should }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end

  context 'lots of params' do
    describe 'varnish class with many params on RedHat' do
      let(:facts) {{
        :osfamily => 'RedHat',
        :operatingsystemmajrelease => '6',
      }}
      let(:params) {{
        :storage_size         => '50%',
        :listen_port          => 80,
        :runtime_params       => {
          'first_byte_timeout' => 10,
          'gzip_level'         => 9
        }
      }}

      it { should compile.with_all_deps }
      it { should contain_file('/etc/sysconfig/varnish') \
        .with_content(/-p first_byte_timeout=10/) }

    end
  end

  context "Varnish 4 on EL6 and EL7" do
    ['6', '7'].each do |operatingsystemmajrelease|
      describe "Varnish 4 on CentOS #{operatingsystemmajrelease}" do
        let(:params) {{
          :varnish_version => '4.0'
        }}
        let (:facts) {{
          :osfamily                  => 'RedHat',
          :operatingsystemmajrelease => operatingsystemmajrelease
        }}

      it { should compile.with_all_deps }
      it { should contain_yumrepo('varnish-cache') \
        .with_baseurl(/4\.0/) }
      end
    end
  end

  context 'Varnish 4 on Ubuntu 14' do
    describe 'Varnish 4 on Ubuntu 14.04' do
      let(:params) {{
          :varnish_version => '4.0'
        }}
        let (:facts) {{
          :osfamily        => 'Debian',
          :lsbdistid       => 'Debian',
          :lsbdistcodename => 'trusty',
        }}

      it { should compile.with_all_deps }
      it { should contain_apt__source('varnish-cache').with(:repos => 'varnish-4.0', 
        :location => 'http://repo.varnish-cache.org/debian') }
    end
  end

end
