<# lo script esegue le seg operazioni

1) ricava l'elenco degli rds session host da analizzare
2) lancia lo script ..\vm\verifica_rds_grace_period.ps1 che valuta i giorni che mancano alla scadenza 
  del grace period su ogni host dell'elenco


Prende due parametri d'ingresso
 la password dell'usr che eseguirà il controllo e l'eventuale  reset del registro
 il nome del vcenter che genera le vdi che costituiscono gli host rds
 
  esempio di utilizzo
  .\reset_graceperiod.ps1 -p password -v vcenter 

  Richiede la presenza dei seguenti script:
  ..\vm\verifica_rds_grace_period.ps1

#>


param ([Parameter(Mandatory)]$password,[Parameter(Mandatory)]$vcenter)
$server = @()


#Ricavo tutti i nomi delle master image di tutte le rds farm
$farms = @(GET-HVfarm)

#per ognuna delle RDS farm ricava il nome di un host attivo

Foreach ($farm in $farms) {

$vmpattern = $farm.AutomatedFarmData.RdsServerNamingSettings.PatternNamingSettings.NamingPattern
$vm = $vmpattern -replace ":","" -replace "=","" -replace "\{\w+\}","" 
$vm = $vm + "01"
$server = $server + $vm
#write-host ($vm)



}
# Mi collego al vcenter che contiene gli host rds da analizzare e lancio lo script che analizza il grace period residuo in giorni



connect-viserver -viserver $vcenter
cd ..\vm
$result = .\verifica_rds_grace_period.ps1 -s $server -p $password
$result
