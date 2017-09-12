Facter.add(:varnish_version) do
  confine :osfamily => 'redhat'
  setcode do
    if Facter::Core::Execution.which('varnishd')
      Facter::Core::Execution.exec('varnishd -V 2>&1')[/varnish-([\d\.]+)/, 1]
    else
      Facter::Core::Execution.exec('yum list varnish')[/varnish\S*\s*([\d\.]+)/, 1]
    end
  end
end

Facter.add(:varnish_version) do
  confine :osfamily => 'debian'
  setcode do
    if Facter::Core::Execution.which('varnishd')
      Facter::Core::Execution.exec('varnishd -V 2>&1')[/varnish-([\d\.]+)/, 1]
    else
      Facter::Core::Execution.exec('apt-cache show varnish')[/Version:\s*([\d\.]+)/, 1]
    end
  end
end
