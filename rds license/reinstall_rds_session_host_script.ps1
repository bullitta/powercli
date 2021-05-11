#stoppa il servizio vmware horizon agent
Stop-service -name "WSNM"
#DISINSTALLO il role "Remote Desktop Service"
Uninstall-WindowsFeature -name "Remote-Desktop-Services"

#Start-Service -name "WSNM"