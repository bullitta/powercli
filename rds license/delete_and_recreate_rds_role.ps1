
<#

lo script effettua le seg operazioni su una vm

1) mette in stato manuale il tipo di avvio dell'horizon view agent
2) stoppa il servizio horizon view agent
3) rimuove il ruolo rds
4) reinstalla il ruolo rds
5) riavvia il servizio Horizon view agent
6) mette in stato automatico il tipo di avvio dell'horizon view agent


delete_and_recreate_rds_role.ps1

#>


set-service -Name WSNM -StartupType Manual

Stop-Service -Name WSNM

Remove-WindowsFeature Remote-Desktop-Services,RDS-Licensing-UI -Restart

Install-WindowsFeature RDS-RD-server,RDS-Licensing,RDS-Connection-Broker,RDS-Web-Access,RDS-Licensing-UI -Restart

Start-Service -Name WSNM

Set-Service -Name WSNM -StartupType Automatic


