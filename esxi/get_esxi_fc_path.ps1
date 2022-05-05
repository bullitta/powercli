<# Effettua una verifica sui path dello storage
su tutti gli esxi presenti in un vcenter

esempio di utilizzo:

.\get_esxi_fc_path.ps1

#>



foreach($esx in Get-VMHost){
  foreach($hba in (Get-VMHostHba -VMHost $esx -Type "FibreChannel")){
    $target = $hba.VMhost.ExtensionData.Config.StorageDevice.ScsiTopology.Adapter | 
      where {$_.Adapter -eq $hba.Key} | %{$_.Target}
    $luns = Get-ScsiLun -Hba $hba -LunType "disk" -ErrorAction SilentlyCOntinue | Measure-Object | Select -ExpandProperty Count
    $nrPaths = $target | %{$_.Lun.Count} | Measure-Object -Sum | select -ExpandProperty Sum
    $hba | Select @{N="VMHost";E={$esx.Name}},@{N="HBA";E={$hba.Name}},
    @{N="Target#";E={if($target -eq $null){0}else{@($target).Count}}},@{N="Device#";E={$luns}},@{N="Path#";E={$nrPaths}}
  }
}
