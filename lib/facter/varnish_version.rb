Facter.add(:varnish_version) do
  setcode do
    if Facter::Core::Execution.which('varnishd')
      Facter::Core::Execution.exec('varnishd -V')
    else
      Facter::Core::Execution.exec('yum list varnish')
    end
  end
end
