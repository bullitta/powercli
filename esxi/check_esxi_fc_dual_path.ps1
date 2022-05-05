<# Effettua una verifica sull'esistenza del dual path dello storage
su tutti gli esxi presenti in un vcenter

Il controllo automatico riguarda il numero delle lun viste da ogni hba di un esxi,
se questo numero è diverso da un hba all'altro allora viene sollevato il problema

esempio di utilizzo:

.\check_esxi_fc_dual_path.ps1

#>


$num_lun = 0

foreach($esx in Get-VMHost){
  $hash = @{}
  foreach($hba in (Get-VMHostHba -VMHost $esx -Type "FibreChannel")){
    $target = $hba.VMhost.ExtensionData.Config.StorageDevice.ScsiTopology.Adapter | 
      where {$_.Adapter -eq $hba.Key} | %{$_.Target}
    $luns = Get-ScsiLun -Hba $hba -LunType "disk" -ErrorAction SilentlyCOntinue | Measure-Object | Select -ExpandProperty Count
    $nrPaths = $target | %{$_.Lun.Count} | Measure-Object -Sum | select -ExpandProperty Sum
    if ($hba.status -eq "online") {
   # $hba | Select @{N="VMHost";E={$esx.Name}},@{N="HBA";E={$hba.Name}},
   # @{N="Target#";E={if($target -eq $null){0}else{@($target).Count}}},@{N="Device#";E={$luns}},@{N="Path#";E={$nrPaths}}
    $hash[$hba.name] = $luns
    $num_lun = $luns
    }
  }
  if ($hash.Count -lt 2) {write-host ("verificare host: $esx ha meno di due hba")}

  else {
  foreach ($h in $hash.keys) {
    # $num_lun

      if ($hash[$h] -ne $num_lun) {
               write-host ("problemi su host: $esx, verificare la corretta visualizzazione delle lun")
              # $num_lun
               #$hash[$h]

                  }
     
      }
      }
}
