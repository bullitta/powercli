<# prende un parametro d'ingresso:

nome del desktop pool su cui esegjuire la verifica

Ed effettua un controllo sullo stato di tutte le macchine del pool
se qualcuna si presenta in stato di errore esegue il reset

esempio d'uso

.\reset_machine_of_pool.ps1 -p mypool




#>

param ([Parameter(Mandatory)]$pool )
# ricava l'elenco nome, stato di tutte le macchine del pool
$all_machine = (get-hvmachine -poolname $pool).base|select name,basicstate 
#$all_machine

# in caso una delle macchine risulti in errore effettua il reset

foreach ($vm in $all_machine) {

if ($vm.basicstate -match "ERROR") {write-host "Resetting vm $vm.name"
                                              reset-hvmachine  -machinename $vm.name -confirm:$false }

 }