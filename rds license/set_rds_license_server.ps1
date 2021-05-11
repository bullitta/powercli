<#
  prende tre parametri d'ingresso:

  elenco macchine in cui effettuare l'impostazione del licensing server
  nome del license server 
  password per accedere alle macchine

  E per funzionare ha bisogno della presenza nella stessa dir dello script
  set_rds_license_server_script.ps1
  Che contiene i seguenti comandi
  $obj = gwmi -namespace "Root\CIMV2\Teminalservices\" Win32_TerminalServiceSettings
  $obj.AddLSToSpecifiedLicenseServerList("Licenseserver")

  
  Esempio di utilizzo

  .\set_rds_license_server.ps1 -s name2,name3 -l yuii -p primo

#>
param ([Parameter(Mandatory)]$servername,[Parameter(Mandatory)]$licenseServer,[Parameter(Mandatory)]$password)



Foreach ($server in $servername) {

$vm = get-vm -name $server

#Copia lo script  nella vm
Get-item "set_rds_license_server_script.ps1"| copy-vmGuestFile -LocalToGuest -VM $vm  -Destination "c:\set_rds_license_server_script.ps1" -guestuser "administrator" -guestpassword $password -confirm:$false -force

#Lancia lo script
$output = Invoke-vmscript -vm $vm -scriptText "c:\set_rds_license_server_script.ps1 -s $licenseServer" -Guestuser "administrator" -guestpassword $password
$outputchomped = $output.scriptoutput -replace "\n",""
write-host ($server + ":  " + $outputchomped)

#rimuove lo script
#Invoke-vmscript -vm $vm -scriptText "del c:\set_rds_license_server_script.ps1" -Guestuser "administrator" -guestpassword $password


#$vm
}