<# Da utilizzare per la rimozione delle vm e degli entitlement
di un desktop pool di tipo dedicato

Prende tre parametri d'ingresso  obbligatori


elenco nomi delle vm
elenco degli user su cui va effettuata la rimozione degli entitlement
nome del pool su cui agire

Ed elimina dal pool di tipo manuale le macchine in elenco rimuovendole anche dal db del vcenter

Esempio di utilizzo

.\remove-machines_from_dedicated_pool.ps1 -v asr,terre -u ddkdk, kdkdk -p seet

#>

param ([Parameter(Mandatory)] $vm,[Parameter(Mandatory)]$user,[Parameter(Mandatory)]$pool )

#Rimozione delle vm

remove-hvmachine -machinename  $vm  -deletefromdisk:$true -confirm:$false

#Rimozione degli entitlement
foreach ($u in $user) {

 remove-hventitlement -user $u -resourcetype desktop -resourcename $pool

}






