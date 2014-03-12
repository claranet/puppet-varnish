require 'spec_helper'

describe 'varnish' do
  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      describe "varnish class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { should compile.with_all_deps }

        it { should contain_class('varnish::params') }

        it { should contain_class('varnish::repo::el6').that_comes_before('varnish::install') }
        it { should contain_class('varnish::secret') }
        it { should contain_class('varnish::install').that_comes_before('varnish::config') }
        it { should contain_class('varnish::config') }
        it { should contain_class('varnish::service').that_subscribes_to('varnish::config') }

        it { should contain_package('varnish') }
        it { should contain_file('/etc/varnish/secret') }
        it { should contain_service('varnish') }
      end
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
end
