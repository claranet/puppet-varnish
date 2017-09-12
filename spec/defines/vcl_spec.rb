require 'spec_helper'

describe 'varnish::vcl' do

  on_supported_os.each do |os, facts|

    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :kernel            => 'Linux',
          :osreleasemaj      => facts[:operatingsystemrelease].split('.').first,
          :pygpgme_installed => true,
        })
      end


      let(:title) { 'vcltest' }

      let(:params) {{
        :content => 'return(lookup)\n',
        :file    => '/etc/varnish/default.vcl'
      }}

      it { should compile.with_all_deps }
      it { should contain_file('/etc/varnish/default.vcl').with_content('return(lookup)\n') }
    end
  end
end
