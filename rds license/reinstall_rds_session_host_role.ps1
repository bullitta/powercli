<# Lo script reinstalla il ruolo rds session host

prende due parametri d'ingresso:
nome del server
password dell'user administrator

L'esecuzione dello script prevede tempi di attesa molto lunghi per i due riavvi del guest host
i riavvi sono due e tra l'uno e l'altro ci sono 20 minuti

esempio di utilizzo

.\reinstall_rds_session_host_role.ps1 -s server1 -p sert3

#>

param ([Parameter(Mandatory)]$servername,[Parameter(Mandatory)]$password)



Foreach ($server in $servername) {

$vm = get-vm -name $server

<#Copia lo script  nella vm
Get-item "uninstall_rds_session_host_script.ps1"| copy-vmGuestFile -LocalToGuest -VM $vm  -Destination "c:\reinstall_rds_session_host_script.ps1" -guestuser "administrator" -guestpassword $password -confirm:$false -force

#Lancia lo script
$output = Invoke-vmscript -vm $vm -scriptText "c:\uninstall_rds_session_host_script.ps1" -Guestuser "administrator" -guestpassword $password
$outputchomped = $output.scriptoutput -replace "\n",""
write-host ($server + ":  " + $outputchomped)



#rimuove lo script dal guest host
Invoke-vmscript -vm $vm -scriptText "del c:\uninstall_rds_session_host_script.ps1" -Guestuser "administrator" -guestpassword $password
#>
##stoppa il servizio vmware horizon agent
Invoke-vmscript -vm $vm -scriptText 'Stop-service -name "WSNM"' -Guestuser "administrator" -guestpassword $password

#disabilita il servizio vmware horizon agent

Invoke-vmscript -vm $vm -scriptText 'Set-service -servicename "WSNM" -StartupType Disabled' -Guestuser "administrator" -guestpassword $password


#DISINSTALLO il role "Remote Desktop Service"
Invoke-vmscript -vm $vm -scriptText 'Uninstall-WindowsFeature -name "Remote-Desktop-Services"' -Guestuser "administrator" -guestpassword $password

#riavvia il guest host
Invoke-vmscript -vm $vm -scriptText "shutdown /r" -Guestuser "administrator" -guestpassword $password

#Attende 10 minuti affinchè il guest host possa ripartire
Write-host "Primo riavvio del Guest-host, dieci minuti di attesa prima della prosec dello script, non interromperlo"
Start-Sleep -Seconds 600

#Installo il role "Remote Desktop Service"
Invoke-vmscript -vm $vm -scriptText 'Install-WindowsFeature -name "Remote-Desktop-Services"' -Guestuser "administrator" -guestpassword $password


#riavvia il guest host
Invoke-vmscript -vm $vm -scriptText "shutdown /r" -Guestuser "administrator" -guestpassword $password

#Attende 10 minuti affinchè il guest host possa ripartire
Write-host "Secondo riavvio del Guest-host, dieci minuti di attesa prima della prosec dello script, non interromperlo"
Start-Sleep -Seconds 600

#Installo il remote desktop session server

Add-WindowsFeature RDS-RD-Server 




#riavvia il guest host per completare l'installazione del rds session host
Invoke-vmscript -vm $vm -scriptText "shutdown /r" -Guestuser "administrator" -guestpassword $password


#Attende 10 minuti affinchè il guest host possa ripartire

Write-Host "Terzo e ultimo riavvio del guest host, non interrompere lo script che riprenderà per l'esecuzione dell'ultimp step tra dieci minuti"
Start-Sleep -Seconds 600



#riabilita il servizio vmware horizon agent

Invoke-vmscript -vm $vm -scriptText 'Set-service -servicename "WSNM" -StartupType Automatic' -Guestuser "administrator" -guestpassword $password

}