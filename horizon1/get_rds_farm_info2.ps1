<# Lo script ricava una serie di parametri delle server farm
utili al sizing e li salva nel file c:\temp\rds.csv

Prende tre parametri d'ingresso: 
 nome del vcenter che gestisce le macchine del pool rds
 nome dell'user con accesso al vcenter
 password dell'user

#>


param ([Parameter(Mandatory)]$user,[Parameter(Mandatory)]$password,[Parameter(Mandatory)]$vcenter)
<#
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
  # $all_farm_new[$fid_new]
  }

  
# Esegue lo stesso tipo di operazione sulle applicazioni, ma questa volta (per via delle presenze multiple) la farmid pulita è il valore dell'hash array

 $applications = (Get-HVApplication)|select data,executiondata
 
 $applications_new = @{}
  
 foreach ($app in $applications) {
  
  $fid = $app.executiondata.farm

  $fid_new = $fid.id -replace ("\/","")
  
  $applications_new.Add($app.data,$fid_new)

  # $applications_new[$app.data]
  }

  
#confronta le due hash array $applications_new e $all_farm_new per ricavare il file csv
 
 foreach ($farm in $all_farm_new.keys) {

  #$farm
  

    foreach ($app in $applications_new.keys) {
  
     #$applications_new[$app]
       
     if ($applications_new[$app] -eq $farm) {
      # $app.name
        
        $ent =  get-hventitlement -resourcetype application -resourcename $app.name -warningaction 0
        if ($ent ) {
                     foreach ($e in $ent) {
                           # $e.base.loginname
                           #elimina dal conto delle utenza abilitate quelle dei gruppi dei trusted domain
                           if(-not $e.base.userprincipalname -and ($e.base.loginname -notmatch "-NOT-RETE")) {
                               #$e.base.loginname
                               $elenco = get-adgroupmember -identity $e.base.loginname|Select -ExpandProperty Name
                               # write-host (($e.base.loginname) + "; " + $all_farm_new[$farm].name + ";" + $app.name + ";" + $elenco.length) 
                               ($all_farm_new[$farm].name+ ";" + $app.name + ";" + $elenco.length) |Out-File -FilePath c:\temp\rds.csv -Append
                             

                               }
                      }                  
                   }
                   
             
                  }
            
           }

     }
     
#>

<#
#cALCOLA il nome di un rds server basandosi sul nome del pattern della rds farm
#ricava l'elenco delle rs farm e delle app dal file rds.csv creato nella fase precedente
$elenco_app = get-content -path c:\temp\rds.csv

foreach ($a in $elenco_app) {

#ricava il nome della farm da $a
$row = $a.split(";")
$farm_name = $row[0]

# ricava il nome dell'host rds dal pattern utilizzato per costruire il pool
$farm = get-hvfarm -farmname $farm_name
$row1 = ($farm.AutomatedFarmData.RdsServerNamingSettings.PatternNamingSettings.namingpattern).split("{")
$rdshostname = $row1[0] + "01"

#crea il nuovo file rds_host.csv identico a rds.csv ma con in più la colonna dei nomi host
$a + ";" + $rdshostname|out-file -FilePath c:\temp\rds_host.csv -Append

}

#>

#collegamento al vcenter per reperire le informazioni sugli host che compongono le farm
 
Connect-VIServer -server $vcenter -user $user -password $password

$elenco_app = get-content -path c:\temp\rds_host.csv

#intestazione colonne  del file finale

"nome farm" + ";" + "nome applicazione" + ";" + "utenti nominali" +  ";" + "vm riferimento" + ";" + "vcore" + ";" + "RAM" + ";" + "disco GB" + ";" + "io rate kps*" + ";" + "full clone" + ";" + "vapp"|out-file -FilePath c:\temp\rds_finale.csv -Append




foreach ($a in $elenco_app) {

#ricava il nome host da $a
$row = $a.split(";")
$host_name = $row[3]

$vm = get-vm -name $host_name

#procedura per il calcolo dell'i/0 rate per i virtual disk
$diskstat = get-stat -entity $vm -disk
$iovalue = ($diskstat.value|measure -Maximum).Maximum


$a + ";" + $vm.numcpu + ";" + $vm.memoryGB + ";" + [math]::round($vm.provisionedspaceGB,0) + ";" + $iovalue + ";" + "no" +";" + "si" |out-file -FilePath c:\temp\rds_finale.csv -Append


}

""|out-file -FilePath C:\temp\rds_finale.csv -Append

"* formula per il calcolo dell'i/o rate: (get-stat -entity $vm -disk)value|measure -Maximum) "|out-file -FilePath C:\temp\rds_finale.csv -Append


     
     

     

 


   