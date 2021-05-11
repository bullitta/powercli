<# Ricava l'elenco dei nomi delle macchine master usate dalle varie farm come golden image
 
  esempio di utilizzo
  .\ricava_nomi_master_farm.ps1

  e scrive sul file elenco_host  i nomi dei template  delle macchine create da ciascuna master

#>

#Ricavo tutti i nomi delle master image di tutte le rds farm
$farms = @(GET-HVfarm)

#rimuovi il file elenco_host
remove-item .\elenco_host



write-host ("Nome farm:    " + "    MASTER                           " + "                        PATTERN NAME")

Foreach ($farm in $farms) {



write-host ($farm.data.name + ":   " + $farm.AutomatedFarmData.VirtualCenterNamesData.ParentVmPath + "      "  + $farm.AutomatedFarmData.RdsServerNamingSettings.PatternNamingSettings.NamingPattern )


$mat = $farm.AutomatedFarmData.RdsServerNamingSettings.PatternNamingSettings.NamingPattern.split("{")
if ($mat.length -gt 1) {$num = $mat[1].substring($mat[1].length-2,1)} 
if ($num -eq "2" ) {$nome =  $mat[0] + "01" 
                    $nomehost = $nomehost + "," + $nome.trim( "`r`n")
                   }
     else {$nomehost =  $farm.AutomatedFarmData.RdsServerNamingSettings.PatternNamingSettings.NamingPattern }

 
#add-content  elenco_host  "$nomehost"

}
#popola il file elenco-host

  add-content  elenco_host  "$nomehost"
