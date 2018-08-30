require 'spec_helper'

describe 'varnish::vcl' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(kernel: 'Linux',
                    osreleasemaj: facts[:operatingsystemrelease].split('.').first,
                    pygpgme_installed: true)
      end

      let(:title) { 'vcltest' }

      let(:params) do
        {
          content: 'return(lookup)\n',
          file: '/etc/varnish/default.vcl',
        }
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_file('/etc/varnish/default.vcl').with_content('return(lookup)\n') }
    end
  end
end
