<# Lo script ricava l'elnco delle subnet attribuite alle farm che stanno su un determinato vcenter
 e li salva nel file c:\temp\rds.csv

Prende tre parametri d'ingresso: 
 nome del vcenter che gestisce le macchine del pool rds
 nome dell'user con accesso al vcenter
 password dell'user

#>


param ([Parameter(Mandatory)]$user,[Parameter(Mandatory)]$password,[Parameter(Mandatory)]$vcenter)

#elimina i vari  file di appoggio rds*.csv
remove-item c:\temp\rds*


# Ricava id e dati delle rds farm

$all_farm = (get-hvfarm)|select id, data

  
  
#elimina il carattere speciale "/" dalla stringa farmid e salva il dato in un hash array dove la chiave è data dalla farmid "ripulita"

    $all_farm_new = @{}

    foreach ($farm in $all_farm) {
    $fid = $farm.id
  
    $fid_new = $fid.id -replace ("\/","")
  #$fid_new
  #ricrea una matrice con il nuovo valore della farm id

  $all_farm_new.Add($fid_new, $farm.data)
  $all_farm_new[$fid_new].name|out-file -FilePath c:\temp\rds.csv -Append
  }

  


#cALCOLA il nome di un rds server basandosi sul nome del pattern della rds farm
#ricava l'elenco delle rs farm e delle app dal file rds.csv creato nella fase precedente
$elenco_farm = get-content -path c:\temp\rds.csv

foreach ($a in $elenco_farm) {



# ricava il nome dell'host rds dal pattern utilizzato per costruire il pool
$farm = get-hvfarm -farmname $a

 #rm.AutomatedFarmData.RdsServerNamingSettings.PatternNamingSettings.namingpattern
     $row1 = ($farm.AutomatedFarmData.RdsServerNamingSettings.PatternNamingSettings.namingpattern).split("{")
     if(!$row1[1]) {$rdshostname = $row1[0] + "1"}
       else {$rdshostname = $row1[0] + "01"}
  
 

     #crea il nuovo file rds_host.csv identico a rds.csv ma con in più la colonna dei nomi host
    $a + ";" + $rdshostname|out-file -FilePath c:\temp\rds_host.csv -Append
    }




#collegamento al vcenter per reperire le informazioni sugli host che compongono le farm
 
Connect-VIServer -server $vcenter -user $user -password $password
$elenco_host = get-content -path c:\temp\rds_host.csv

foreach ($a in $elenco_host) {

#ricava il nome host da $a
$row = $a.split(";")
$host_name = $row[1]

$vm = get-vm -name $host_name
if ($vm.powerstate -eq "PoweredOn") {
                  #procedura per il calcolo della subnet
                  $subnet = $vm.Extensiondata.guest.ipstack.iprouteconfig.iproute.network[1] + "/" + $vm.Extensiondata.guest.ipstack.iprouteconfig.iproute.PrefixLength[1]
                  $p + ";" + $subnet|out-file -FilePath c:\temp\pool_subnet.csv -Append
                 $subnet_list = $subnet_list + " " + $subnet
                  }



}
$subnet_list.Split(" ")|Sort-Object|Get-Unique

     
#>
 


   