<# Da utilizzare per l'aggiunta delle   vm e degli entitlement
di un desktop pool di tipo dedicato

Prende tre parametri d'ingresso  obbligatori


elenco nomi delle vm
elenco degli user a cui va assegnata la vm (nel nome user non mettere il dominio)
nome del pool su cui agire



Esempio di utilizzo

.\create_machines_for_dedicated_pool.ps1 -v asr,terre -u ddkdk, kdkdk -p seet

#>



param ([Parameter(Mandatory)] $vm,[Parameter(Mandatory)]$user,[Parameter(Mandatory)]$pool )



Add-HVDesktop -poolname $pool  -machines $vm -users $user