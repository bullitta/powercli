<# Da utilizzare per l'aggiunta di nuove vm e assegnazione user al pool nexive
in base al numero di frazionario

Prende cinque parametri d'ingresso  obbligatori


nome del frazionario
 user cui vanno assegnate la nuova macchina
OU path dove deve essere registrata la nuova macchina
horizion user admin
password dell'horizon user admin

E RICHIEDE la presenza nella stessa directory dei due script powercli:

assign_new_machine_nexive_to_ad_forest.ps1
assign_new_machine_to_nexive_pool.ps1
e dello script add_users_to_group.ps1
Esempio di utilizzo

.\assign_new_machine_to_ad_forest_and_to_nexive_pool.ps1 -f asr -u ddkdk -u admin -p password

#>




param ([Parameter(Mandatory)] $frazionario, [Parameter(Mandatory)] $user, [Parameter(Mandatory)]$OUpath, [Parameter(Mandatory)]$admin, [Parameter(Mandatory)]$password )

#Primo step, verifica sel l'user è già presente tra gli assegnatari delle vm e se lo è interrompe l'esecuzione




 $uFullName = "rete.poste\" + $user

 $ent = (get-hventitlement -resourcetype desktop -resourcename POOL-NEXIVE-PRODUZIONE -user $uFullName).id


 if ($ent) {

       $uid = ($ent.id).tostring()
       $id_ent = ($uid.split("/"))[1]


     $machine_user = (get-hvmachinesummary -poolname POOL-NEXIVE-PRODUZIONE).base.user
     
     foreach ($u in $machine_user) {
      $u_id = ($u.id).tostring()
      
      $identity = ($u_id.split("/"))[1]
     

         if ($id_ent -eq $identity) {
            write-host ("User: " + $user + " già presente negli entitlement del pool POOL-NEXIVE-PRODUZIONE e già assegnato ad una macchina, verificare meglio")
             exit;
            }
   
      }
 }



# Secondo step assegna gli utenti al gruppo VDI-POOL-NEXIVE-PRODUZIONE  

..\ad\add_users_to_group.ps1 -g VDI-POOL-NEXIVE-PRODUZIONE -u $user



#Terzo step assegna la nuova macchina alla foresta ad

.\assign_new_machine_nexive_to_ad_forest.ps1 -f $frazionario  -O $OUpath  -a $admin -p $password



#Quarto step crea la nuova macchina e l'assegna agli user indicati

.\assign_new_machines_to_nexive_pool.ps1 -f $frazionario -u $user

