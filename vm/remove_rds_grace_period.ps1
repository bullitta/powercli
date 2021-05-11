<#
  prende due parametri d'ingresso:

  elenco macchine in cui effettuare il reset  del graceperiod registry
  password per accedere alle macchine

  E per funzionare ha bisogno della presenza nella stessa dir dello script
  reset_grace_period_script.ps1
  Che contiene i seguenti comandi


  
  Esempio di utilizzo

  .\remove_rds_grace_period.ps1 -s name2,name3 -p primo

#>

param ([Parameter(Mandatory)]$servername,[Parameter(Mandatory)]$password)



Foreach ($server in $servername) {
$server = $server
$vm = get-vm -name $server

#Copia lo script  nella vm
Get-item "reset_grace_period_script.ps1"| copy-vmGuestFile -LocalToGuest -VM $vm  -Destination "c:\reset_grace_period_script.ps1" -guestuser "administrator" -guestpassword $password -confirm:$false -force

#Lancia lo script
$output = Invoke-vmscript -vm $vm -scriptText "c:\reset_grace_period_script.ps1" -Guestuser "administrator" -guestpassword $password
$outputchomped = $output.scriptoutput -replace "\n",""
write-host ($server + ":  " + $outputchomped)


}

