#script powershell  utilizzato per la predisposizione della directory McAffe_endpoint sui template windows
#funziona in abbinamento allo script powercli "aggiorna_agent_antivirus.ps1" che lo trasferisce sulla vm
#dove deve essere effettuato l'aggiornamento dell'agent
#in pratica esegue le seguenti operazioni

# si posiziona sulla dir c:\software\antivirus\windows
#rinomina la cartella McAfee_Endpoint_security in McAfee_Endpoint_security_old
#Unzippa il file McAfee_Endpoint_Security_10.7.0.667.6_standalone_client_install.zip 
#elimina il file McAfee_Endpoint_Security_10.7.0.667.6_standalone_client_install.zip


Set-location -Path c:\software\Antivirus\Windows
rename-item McAfee_Endpoint_Security McAfee_Endpoint_Security_10.6.1
new-item -itemtype "directory" -Path "c:\software\Antivirus\Windows" -Name "McAfee_Endpoint_Security"
Expand-Archive -LiteralPath McAfee_Endpoint_Security_10.7.0.667.6_standalone_client_install.zip -DestinationPath McAfee_Endpoint_Security
remove-item -Path McAfee_Endpoint_Security_10.7.0.667.6_standalone_client_install.zip

