<# Lo script ricava le subnet definite per tutti i desktop pool attivi in un determinato vcenter
 e li salva nel file c:\temp\pool_subnet.csv
 produce inoltre un elenco di tutte le subnet assegnate ai pool

Prende tre parametri d'ingresso: 
 nome del vcenter che gestisce le macchine del pool rds
 nome dell'user con accesso al vcenter
 password dell'user

 esempio di esecuzione

 .\get_desktop_pool_subnet.ps1 -v vcenter -u posta\rossi -p zfa

#>


param ([Parameter(Mandatory)]$user,[Parameter(Mandatory)]$password,[Parameter(Mandatory)]$vcenter)

#elimina i vari  file di appoggio pool*.csv


remove-item c:\temp\pool*


# Ricava i dati dei desktop pool abilitati

$all_pool = (get-hvpool)|where {$_.DesktopSettings.enabled -eq "True"}|select id,base,source

 
 foreach ($pool in $all_pool) {
 $pool.base.name |Out-File -FilePath c:\temp\pool.csv -Append
 }


#cALCOLA il nome di un host del pool basandosi sul nome del pattern del pool e salva il risultato in un nuovo file c:\temp\pool_host.csv 

#ricava l'elenco dei pool dal file pool.csv creato nella fase precedente
$elenco_pool = get-content -path c:\temp\pool.csv

foreach ($p in $elenco_pool) {



$pool = get-hvpool -poolname $p
 if ($pool.source -eq "INSTANT_CLONE_ENGINE" ) {
              #ricavo il primo nome di una vm appartenente al pool
              $hvm = get-hvmachine -poolname $pool.base.name |select-object -first 1
              $hvmName = $hvm.base.name
            # $row1 = ($pool.AutomatedDesktopData.VmNamingSettings.PatternNamingSettings.namingpattern).split("{")
            # $poolhostname = $row1[0] + "01"
             #crea il nuovo file pool_host.csv identico a pool.csv ma con in più la colonna dei nomi host
            if ($hvmName ) {$p + ";" + $hvmName|out-file -FilePath c:\temp\pool_host.csv -Append}
             }
  if ($pool.source -eq "VIRTUAL_CENTER") {
      #ricavo il primo nome di una vm appartenente al pool
      $hvm = get-hvmachine -poolname $pool.base.name |select-object -first 1
      $hvmName = $hvm.base.name
      if ($hvmName ) {  $p + ";" + $hvmName|out-file -FilePath c:\temp\pool_host.csv -Append}
        }



     

}





# Recupera le informazioni relative alle subnet adoperate dai vari pool

#collegamento al vcenter per reperire le informazioni sugli host che compongono il pool
 
Connect-VIServer -server $vcenter -user $user -password $password

$elenco_pool = get-content -path c:\temp\pool_host.csv

 $subnet_list = ""
foreach ($p in $elenco_pool) {

#ricava il nome host da $p 
$row = $p.split(";")
$host_name = $row[1]
#$host_name

#$subnet_list = @()

$vm = get-vm -name $host_name
if ($vm.powerstate -eq "PoweredOn") {
                  #procedura per il calcolo della subnet
                  $subnet = $vm.Extensiondata.guest.ipstack.iprouteconfig.iproute.network[1] + "/" + $vm.Extensiondata.guest.ipstack.iprouteconfig.iproute.PrefixLength[1]
                  $p + ";" + $subnet|out-file -FilePath c:\temp\pool_subnet.csv -Append
                 $subnet_list = $subnet_list + " " + $subnet
                  }

 }
  $subnet_list.Split(" ")|Sort-Object|Get-Unique


