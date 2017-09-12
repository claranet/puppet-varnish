Facter.add(:varnish_version) do
  setcode do
    if Facter::Core::Execution.which('varnishd')
      Facter::Core::Execution.exec('varnishd -V 2>&1')
    else
      Facter::Core::Execution.exec('yum list varnish')
    end
  end
end
