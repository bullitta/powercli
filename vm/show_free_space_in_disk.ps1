<#
  prende due parametri d'ingresso:

  elenco macchine in cui effettuare la verifica sullo spazio disco occupato
  password per accedere alle macchine

  RICHIEDE la presenza sulla stessa dir dello script show_disk_space_script.ps1


  
  Esempio di utilizzo

  .\show_free_space_in_disk.ps1 -s name2,name3 -p primo

#>

param ([Parameter(Mandatory)]$servername,[Parameter(Mandatory)]$password)



Foreach ($server in $servername) {

$vm = get-vm -name $server

#Copia lo script  nella vm
Get-item "show_disk_space_script.ps1"| copy-vmGuestFile -LocalToGuest -VM $vm  -Destination "c:\show_disk_space_script.ps1" -guestuser "administrator" -guestpassword $password -confirm:$false -force

#Lancia il comando 
$output = Invoke-vmscript -vm $vm -scriptText "c:\show_disk_space_script.ps1" -Guestuser "administrator" -guestpassword $password
#$outputchomped = $output.scriptoutput -replace "\n",""
write-host ($server + ":  " + $output)

#RIMUOVE lo script dal guest host
Invoke-vmscript -vm $vm -scriptText "del c:\show_disk_space_script.ps1" -Guestuser "administrator" -guestpassword $password
}