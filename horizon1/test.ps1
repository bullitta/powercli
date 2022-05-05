&{foreach($vm in (Get-Cluster | Get-VM)){
    $vm.ExtensionData.Guest.Net | Select @{N="VM";E={$vm.Name}},MacAddress,Network,
    @{N="DHCP";E={$_.IpConfig.Dhcp.Ipv4.Enable}},
    @{N="IP";E={$_.IpAddress[0]}},
    @{N="Subnet Mask";E={
            $dec = [Convert]::ToUInt32($(("1" * $_.IpConfig.IpAddress[0].PrefixLength).PadRight(32, "0")), 2)
            $DottedIP = $( For ($i = 3; $i -gt -1; $i--) {
                    $Remainder = $dec % [Math]::Pow(256, $i)
                    (                        $dec - $Remainder) / [Math]::Pow(256, $i)
                    $dec = $Remainder
                } )
            [String]::Join('.', $DottedIP) 
        }}
}} | Export-Csv -Path report.csv -NoTypeInformation -UseCulture