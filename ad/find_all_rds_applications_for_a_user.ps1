<# 
Lo script trova l'elenco dei nomi delle applicazioni rds a cui un utente è stato abilitato

esempio d'uso:
.\find_all_rds_applications_for_a_user.ps1 -u ritog@rete.finanza

Attenzione consente di rilevare solo le assegnazioni dirette sull'user, non quelle effettuate attraverso dei gruppi
#>

param ([Parameter(Mandatory)]$user)
#Ricava l'elenco delle applicazioni
$all_application = get-hvapplication

#Ricava l'elenco di tutti gli entitlement in cui un user è presente
$all_ent = get-hventitlement -user $user

#Salva nel file temporaneo app_id l'elenco delle application id abilitate

$ent_app = $all_ent.localdata|select -expand applications|ft -HideTableHeaders > app_id



 # Confronto tra contenuto file app_id ed elenco applicazioni 
 
   foreach ($line in get-content .\app_id) {
    $line = $line.trim() 
    if ($line -ne "") {
      foreach ( $app in $all_application) {

         $app_id = $app|select -expand id|ft -HideTableHeaders >  app_id1
         $app_id = get-content .\app_id1
         $app_id = $app_id.Trim()
         if ($app_id -match $line) {$app.data.name }
      
       } 
    }
  }
  # Rimozione file temporanei
  Remove-Item .\app_id
  Remove-Item .\app_id1
   