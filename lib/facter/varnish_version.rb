Facter.add(:varnish_version) do
  confine :osfamily => 'redhat'
  setcode do
    # If executable is available, use it to query installed version
    if Facter::Core::Execution.which('varnishd')
      Facter::Core::Execution.exec('varnishd -V 2>&1')[/varnish-([\d\.]+)/, 1]
    # Otherwise, pick first* version listed from Yum
    else
      Facter::Core::Execution.exec('yum list varnish')[/varnish\S*\s*([\d\.]+)/, 1]
    end
  end
end

Facter.add(:varnish_version) do
  confine :osfamily => 'debian'
  setcode do
    # If executable is available, use it to query installed version
    if Facter::Core::Execution.which('varnishd')
      Facter::Core::Execution.exec('varnishd -V 2>&1')[/varnish-([\d\.]+)/, 1]
    # Otherwise, pick first* version listed from Apt
    else
      Facter::Core::Execution.exec('apt-cache show varnish')[/Version:\s*([\d\.]+)/, 1]
    end
  end
end

# * I'm optimistically assuming the first listed version
# is the highest one available
