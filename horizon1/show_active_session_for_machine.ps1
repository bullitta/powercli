<# Calcola il numero delle sessioni attive in una server farm
 macchina x macchina


Esempio di utilizzo

.\show_active_session_for_machine.ps1 -f prova

#>



param ([Parameter(Mandatory)]$farm)

$array = @{}

$sessionData = (Get-HVLocalSession).namesdata|where {$_.FarmName -eq "$farm"}
foreach ($m in $sessionData) {

  

  $array[$m.MachineOrRDSServerName] =  $array[$m.MachineOrRDSServerName] + 1

}


foreach ($a in $array.Keys) {

 write-host ($a + ": " + $array[$a])

 $total = $total + $array[$a]

}

write-host ("Totale sessioni: " + $total )
