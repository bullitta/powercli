<#
  prende due parametri d'ingresso:

  elenco macchine in cui effettuare la lettura del licensing server
  password per accedere alle macchine

  E per funzionare ha bisogno della presenza nella stessa dir dello script
  get_rds_license_server_script.ps1
  Che contiene i seguenti comandi
  $obj = gwmi -namespace "Root\CIMV2\Teminalservices\" Win32_TerminalServiceSettings
  $obj.GetSpecifiedLicenseServerList("Licenseserver")

  
  Esempio di utilizzo

  .\get_rds_license_server.ps1 -s name2,name3 -p primo

#>
param ([Parameter(Mandatory)]$servername,[Parameter(Mandatory)]$password)



Foreach ($server in $servername) {

$vm = get-vm -name $server|where-object {$_.powerstate -eq "PoweredOn"}

#Copia lo script  nella vm
Get-item "get_rds_license_server_script.ps1"| copy-vmGuestFile -LocalToGuest -VM $vm  -Destination "c:\get_rds_license_server_script.ps1" -guestuser "administrator" -guestpassword $password -confirm:$false -force

#Lancia lo script
$output = Invoke-vmscript -vm $vm -scriptText "c:\get_rds_license_server_script.ps1" -Guestuser "administrator" -guestpassword $password
$outputchomped = $output.scriptoutput -replace "\n",""
write-host ($server + ":  " + $outputchomped)

#$vm
}


