# frozen_string_literal: true

require 'spec_helper'

describe 'varnish', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      # Temporary variable before remove init support
      systemd = (
        facts[:os]['family'] == 'RedHat' &&
        facts[:os]['release']['major'].to_i >= 7
      ) || (
        facts[:os]['release']['name'] == 'Ubuntu' &&
        facts[:os]['release']['major'].to_f >= 16.04
      ) || (
        facts[:os]['release']['name'] == 'Debian' &&
        facts[:os]['release']['major'].to_i >= 8
      )

      context 'with default params' do
        it { is_expected.to contain_class('varnish::params') }
        it { is_expected.to contain_class('varnish::repo') }
        it { is_expected.to contain_class('varnish::install') }
        it { is_expected.to contain_class('varnish::secret') }
        it { is_expected.to contain_class('varnish::config') }
        it { is_expected.to contain_class('varnish::service') }

        if facts[:os]['family'] == 'RedHat'
          it { is_expected.to contain_class('epel') }

          it do
            is_expected.to contain_yumrepo('varnish-cache').with(
              descr: 'varnishcache_varnish41',
              baseurl: format(
                'https://packagecloud.io/varnishcache/varnish41/el/%s/$basearch',
                facts[:os]['release']['major']
              ),
              gpgkey: 'https://packagecloud.io/varnishcache/varnish41/gpgkey',
              metadata_expire: '300',
              repo_gpgcheck: '1',
              gpgcheck: '0',
              sslverify: '1',
              sslcacert: '/etc/pki/tls/certs/ca-bundle.crt'
            )
          end

          it do
            is_expected.to contain_yumrepo('varnish-cache-source').with(
              descr: 'varnishcache_varnish41-source',
              baseurl: format(
                'https://packagecloud.io/varnishcache/varnish41/el/%s/SRPMS',
                facts[:os]['release']['major']
              ),
              gpgkey: 'https://packagecloud.io/varnishcache/varnish41/gpgkey',
              metadata_expire: '300',
              repo_gpgcheck: '1',
              gpgcheck: '0',
              sslverify: '1',
              sslcacert: '/etc/pki/tls/certs/ca-bundle.crt'
            )
          end
        else
          it { is_expected.to contain_package('apt-transport-https') }

          it do
            is_expected.to contain_apt__source('varnish-cache').with(
              comment: 'Apt source for Varnish 4.1',
              location: format(
                'https://packagecloud.io/varnishcache/varnish41/%s/',
                facts[:os]['name'].downcase
              ),
              repos: 'main',
              require: 'Package[apt-transport-https]',
              key: {
                'source' => 'https://packagecloud.io/varnishcache/varnish41/gpgkey',
                'id' => '9C96F9CA0DC3F4EA78FF332834BF6E8ECBF5C49E',
              },
              include: {
                'deb' => true,
                'src' => true,
              }
            )
          end
        end

        it { is_expected.to contain_package('varnish') }

        it do
          is_expected.to contain_file('/etc/varnish/secret').with(
            owner: 'root',
            group: 'varnish',
            mode: '0640'
          )
        end

        it do
          is_expected.to contain_exec('Generate Varnish secret file').with(
            unless: "/bin/egrep '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' '/etc/varnish/secret' >/dev/null",
            command: "/bin/cp /proc/sys/kernel/random/uuid '/etc/varnish/secret'"
          )
        end

        it do
          sysconfig = if facts[:os]['family'] == 'RedHat'
                        '/etc/sysconfig/varnish'
                      else
                        '/etc/default/varnish'
                      end
          is_expected.to contain_file(sysconfig).with(
            owner: 'root',
            group: 'root',
            mode: '0644'
          )
        end

        varnish_reload = if facts[:os]['family'] == 'RedHat'
                           '/usr/sbin/varnish_reload_vcl'
                         else
                           '/usr/share/varnish/reload-vcl -q'
                         end

        if systemd
          it do
            is_expected.to contain_file('/etc/systemd/system/varnish.service').
              with(
                ensure: 'file',
                owner: 'root',
                group: 'root',
                mode: '0644',
                notify: 'Exec[varnish_systemctl_daemon_reload]',
                content: <<~EOF
                  [Unit]
                  Description=Varnish HTTP accelerator
                  After=network.target

                  [Service]
                  Type=forking
                  LimitNOFILE=131072
                  LimitMEMLOCK=82000
                  LimitCORE=infinity
                  PrivateTmp=true

                  ExecReload=#{varnish_reload}
                  ExecStart=/usr/sbin/varnishd -j unix,user=varnish,ccgroup=varnish \\
                    -P /var/run/varnish.pid \\
                    -t 120 \\
                    -f /etc/varnish/default.vcl \\
                      -a 0.0.0.0:6081 \\
                      -T 127.0.0.1:6082 \\
                    -p thread_pool_min=50 \\
                    -p thread_pool_max=1000 \\
                    -p thread_pool_timeout=120 \\
                    -S /etc/varnish/secret \\
                    -s file,/var/lib/varnish/varnish_storage.bin,1G \\

                  [Install]
                  WantedBy=multi-user.target
                EOF
              )
          end

          it do
            is_expected.to contain_exec('varnish_systemctl_daemon_reload').with(
              command: '/bin/systemctl daemon-reload',
              refreshonly: true,
              require: 'File[/etc/systemd/system/varnish.service]',
              notify: 'Service[varnish]'
            )
          end
        end

        it do
          is_expected.to contain_exec('vcl_reload').with(
            command: varnish_reload,
            refreshonly: true,
            require: 'Service[varnish]'
          )
        end

        it do
          is_expected.to contain_service('varnish').with(
            ensure: 'running',
            enable: true
          )
        end

        describe 'with selinux_current_mode to enforcing' do
          let(:facts) { super().merge(selinux_current_mode: 'enforcing') }

          if facts[:os]['family'] == 'RedHat' && facts[:os]['release']['major'] == '6'
            it do
              is_expected.to contain_selinux__module('varnishpol').with(
                ensure: 'present',
                source_te: 'puppet:///modules/varnish/varnishpol.te',
                notify: 'Service[varnish]'
              )
            end
          end
        end
      end

      context 'with runtime_params' do
        let(:params) do
          { runtime_params: { accept_filter: true, acceptor_sleep_max: 10 } }
        end

        if systemd
          it do
            is_expected.to contain_file('/etc/systemd/system/varnish.service').
              with(
                content: %r{-p accept_filter=true \\\n  -p acceptor_sleep_max=10}
              )
          end
        end
      end

      context 'with addrepo at false' do
        let(:params) { { addrepo: false } }

        it { is_expected.not_to contain_class('varnish::repo') }
      end

      context 'with secret at supersecret' do
        let(:params) { { secret: 'supersecret' } }

        it { is_expected.not_to contain_exec('Generate Varnish secret file') }

        it do
          is_expected.to contain_file('/etc/varnish/secret').with(
            owner: 'root',
            group: 'varnish',
            mode: '0640',
            content: "supersecret\n"
          )
        end
      end

      context 'with storage_type at malloc' do
        let(:params) { { storage_type: 'malloc' } }

        if systemd
          it do
            is_expected.to contain_file('/etc/systemd/system/varnish.service').
              with(
                content: %r{-s malloc,1G}
              )
          end
        end
      end

      context 'with storage_additional define' do
        let(:params) do
          { storage_additional: ['malloc,2G', 'file,/tmp/fast,1G'] }
        end

        if systemd
          it do
            is_expected.to contain_file('/etc/systemd/system/varnish.service').
              with(
                content: %r{-s malloc,2G \\\n  -s file,/tmp/fast,1G}
              )
          end
        end
      end

      context 'with vcl_reload_cmd define' do
        let(:params) { { vcl_reload_cmd: '/bin/varnish reload' } }

        it do
          is_expected.to contain_exec('vcl_reload').with(
            command: '/bin/varnish reload'
          )
        end

        if systemd
          it do
            is_expected.to contain_file('/etc/systemd/system/varnish.service').
              with(
                content: %r{ExecReload=/bin/varnish reload}
              )
          end
        end
      end

      context 'with lts version' do
        let(:params) { { varnish_version: '6.0lts' } }

        if facts[:os]['family'] == 'RedHat'
          unless facts[:os]['release']['major'] == '6'
            it do
              is_expected.to contain_yumrepo('varnish-cache').with(
                descr: 'varnishcache_varnish60lts',
                baseurl: format(
                  'https://packagecloud.io/varnishcache/varnish60lts/el/%s/$basearch',
                  facts[:os]['release']['major']
                ),
                gpgkey: 'https://packagecloud.io/varnishcache/varnish60lts/gpgkey'
              )
            end

            it do
              is_expected.to contain_yumrepo('varnish-cache-source').with(
                descr: 'varnishcache_varnish60lts-source',
                baseurl: format(
                  'https://packagecloud.io/varnishcache/varnish60lts/el/%s/SRPMS',
                  facts[:os]['release']['major']
                ),
                gpgkey: 'https://packagecloud.io/varnishcache/varnish60lts/gpgkey'
              )
            end
          end
        else
          unless facts[:os]['release']['major'] =~ %r{(7|8|14\.04)}
            it do
              is_expected.to contain_apt__source('varnish-cache').with(
                comment: 'Apt source for Varnish 6.0lts',
                location: format(
                  'https://packagecloud.io/varnishcache/varnish60lts/%s/',
                  facts[:os]['name'].downcase
                ),
                key: {
                  'source' => 'https://packagecloud.io/varnishcache/varnish60lts/gpgkey',
                  'id' => '48D81A24CB0456F5D59431D94CFCFD6BA750EDCD'
                }
              )
            end
          end
        end
      end
    end
  end
end
