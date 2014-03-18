require 'spec_helper'

describe 'varnish::vcl' do
  context 'vcl content' do
    let(:title) { 'vcltest' }
    let(:facts) {{
      :osfamily => 'RedHat'
    }}
    let(:params) {{
      :content => 'return(lookup)\n',
      :file    => '/etc/varnish/default.vcl'
    }}


    it { should compile.with_all_deps }
    it { should contain_file('/etc/varnish/default.vcl') \
      .with_content('return(lookup)\n') }
  end
end
