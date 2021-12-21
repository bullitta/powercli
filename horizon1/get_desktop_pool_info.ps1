<# Lo script ricava una serie di parametri dei desktop pool
utili al sizing e li salva nel file c:\temp\pool_finale.csv

Prende tre parametri d'ingresso: 
 nome del vcenter che gestisce le macchine del pool rds
 nome dell'user con accesso al vcenter
 password dell'user

#>


param ([Parameter(Mandatory)]$user,[Parameter(Mandatory)]$password,[Parameter(Mandatory)]$vcenter)

#elimina i vari  file di appoggio pool*.csv


remove-item c:\temp\pool*


# Ricava i dati dei desktop pool abilitati

$all_pool = (get-hvpool)|where {$_.DesktopSettings.enabled -eq "True"}|select id,base,source

 

  

  
  


  
#per ogni pool ritrova gli entitlement e il numero di utenti associati e salva la info nel  file pool.csv
 
# $directEntitlement = @()
 foreach ($pool in $all_pool) {
   # $pool.source
   # $num_user = 0

   #analizza i pool di tipo instanclone
   if ($pool.source -eq "INSTANT_CLONE_ENGINE") {

     $ent = get-hventitlement -resourcetype desktop -resourcename $pool.base.name
    
     foreach ($e in $ent) {
       
        <# questo pezzo è commentato i pool di tipo instanclone che hanno assegnazione diretta delle utenze possono essere trascurati
          if ($ent -and (-not $e.base.group)) {
                          $num_user = $num_user + 1
                          # $pool.base.name
         
                        }
        #>
            
          # escludi i pool privi di entitlement o quelli che nell'entitlement hanno assegnazione diretta delle utenze
             if ($ent -and  ($e.base.group)) {
                              $elenco = get-adgroupmember -identity $e.base.loginname|Select -ExpandProperty Name
                               # write-host (($e.base.loginname) + "; " + $all_farm_new[$farm].name + ";" + $app.name + ";" + $elenco.length) 
                               $pool.base.name+ ";" + $pool.base.description + ";" + $elenco.length + ";" + "instant clone"|Out-File -FilePath c:\temp\pool.csv -Append
                             }
                                
                                  
             
            }
      
       }
  
   #analizza i dedicated pool
   if ($pool.source -eq "VIRTUAL_CENTER") {
   
     $ent = get-hventitlement -resourcetype desktop -resourcename $pool.base.name
     foreach ($e in $ent) {
                if ($e.base.group -eq "True") {
                                              $elenco = get-adgroupmember -identity $e.base.loginname|Select -ExpandProperty Name
                                              $num_user =  $elenco.length
                                              }
                 else   {
                          $num_user = ($ent|measure-object -line).Lines 
                         
                        }
                }
        $pool.base.name + ";" + $pool.base.description + ";" + $num_user + ";" + "dedicato"|Out-File -FilePath c:\temp\pool.csv -Append
     }
   }

  

  





#cALCOLA il nome di un host del pool basandosi sul nome del pattern del pool e salva il risultato in un nuovo file c:\temp\pool_host.csv 

#ricava l'elenco dei pool dal file pool.csv creato nella fase precedente
$elenco_pool = get-content -path c:\temp\pool.csv

foreach ($p in $elenco_pool) {

#ricava il nome del pool da $p
$row = $p.split(";")
$pool_name = $row[0]

# ricava il nome dell'host  dal pattern utilizzato per costruire il pool


$pool = get-hvpool -poolname $pool_name
 if ($pool.source -eq "INSTANT_CLONE_ENGINE" ) {
              #ricavo il primo nome di una vm appartenente al pool
              $hvm = get-hvmachine -poolname $pool.base.name |select-object -first 1
              $hvmName = $hvm.base.name
            # $row1 = ($pool.AutomatedDesktopData.VmNamingSettings.PatternNamingSettings.namingpattern).split("{")
            # $poolhostname = $row1[0] + "01"
             #crea il nuovo file pool_host.csv identico a pool.csv ma con in più la colonna dei nomi host
             $p + ";" + $hvmName|out-file -FilePath c:\temp\pool_host.csv -Append
             }
  if ($pool.source -eq "VIRTUAL_CENTER") {
      #ricavo il primo nome di una vm appartenente al pool
      $hvm = get-hvmachine -poolname $pool.base.name |select-object -first 1
      $hvmName = $hvm.base.name
        $p + ";" + $hvmName|out-file -FilePath c:\temp\pool_host.csv -Append
        }



     

}





# Recupera le informazioni relative alle macchine che costituiscono il pool

#collegamento al vcenter per reperire le informazioni sugli host che compongono il pool
 
Connect-VIServer -server $vcenter -user $user -password $password

$elenco_pool = get-content -path c:\temp\pool_host.csv

#intestazione colonne  del file  pool_finale.csv

"nome pool" + ";" + "descrizione" + ";" + "utenti nominali" +  ";" + "tipo pool" + ";" + "vm riferimento" + ";" + "vcore" + ";" + "RAM" + ";" + "disco GB" + ";" + "io rate kps*"  |out-file -FilePath c:\temp\pool_finale.csv -Append




foreach ($p in $elenco_pool) {

#ricava il nome host da $p
$row = $p.split(";")
$host_name = $row[4]
#$host_name



$vm = get-vm -name $host_name
if ($vm.powerstate -eq "PoweredOn") {
                  #procedura per il calcolo dell'i/0 rate per i virtual disk
                  $diskstat = get-stat -entity $vm -disk
                  $iovalue = ($diskstat.value|measure -Maximum).Maximum
                  $p + ";" + $vm.numcpu + ";" + $vm.memoryGB + ";" + [math]::round($vm.provisionedspaceGB,0) + ";" + $iovalue  |out-file -FilePath c:\temp\pool_finale.csv -Append
                  }

}

""|out-file -FilePath C:\temp\pool_finale.csv -Append

"* formula per il calcolo dell'i/o rate: (get-stat -entity $vm -disk)value|measure -Maximum) "|out-file -FilePath C:\temp\pool_finale.csv -Append


     
    

  




   