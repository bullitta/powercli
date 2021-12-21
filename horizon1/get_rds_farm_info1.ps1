<# Lo script ricava una serie di parametri delle server farm
utili al sizing e li salva nel file c:\temp\rds.csv


#>

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
     
     
     

     

 


   