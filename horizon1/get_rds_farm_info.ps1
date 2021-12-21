<# Lo script ricava una serie di parametri delle server farm
utili al sizing


#>

# Ricava nomi e descrizione delle rds farm

#(get-hvfarm).data|select displayname, description


#ritrova gli entitlement complessivi per ogni rds farm

  #trova le farm id

  #$farmid = (get-hvapplication).id
  #$farmid
 
  # per ogni farm trova l'elenco di tutti gli entitlement associati a tutte le applicazioni definite sulla farm
  #$rdsh_farmid = (get-hvfarm).id
  $all_farm = (get-hvfarm)|select id, data

  
  
  #elimina il carattere speciale "/" dalla stringa farmid

  $all_farm_new = @{}

  foreach ($farm in $all_farm) {
  $fid = $farm.id
  
  $fid_new = $fid.id -replace ("\/","")
  #$fid_new
  #ricrea una matrice con il nuovo valore della farm id

  $all_farm_new.Add($fid_new, $farm.data)
# $all_farm_new[$fid_new]
  }

  

  # Esegue le stesse operazioni sulle applicazioni

 
  $applications = (Get-HVApplication)|select data,executiondata

  $applications_new = @{}
  
  foreach ($app in $applications) {
  
  $fid = $app.executiondata.farm

  $fid_new = $fid.id -replace ("\/","")
  
  $applications_new.Add($app.data,$fid_new)

 # $applications_new[$app.data]
  }

  
 
  foreach ($farm in $all_farm_new.keys) {
#  write-host ("farm")
  #$farm
  

    foreach ($app in $applications_new.keys) {
   # write-host("app")
    #    $applications_new[$app]
           
           
          if ($applications_new[$app] -eq $farm) {
        #  $app.name
           
                 
           $ent =  get-hventitlement -resourcetype application -resourcename $app.name -warningaction 0
          # $IsGroup = $ent.base.group
             #$IsGroup
             if ($ent -and ( -not $ent.base.lastname)) {
             
             $elenco = get-adgroupmember -identity $ent.base.loginname|Select -ExpandProperty Name
             
             write-host (($ent.base.loginname) + "; " + $all_farm_new[$farm].name + ";" + $app.name + ";" + $elenco.length) >> rds.txt
           # ("$all_farm_new[$farm].name"+ ";" + "$app.name" + ";" ) |Out-File -FilePath rds.txt
            }
           }

     }
     
     
     
}
     

 


   