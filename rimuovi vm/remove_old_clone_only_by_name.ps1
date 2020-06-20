<# Rimuovi in maniera permanente un insieme di vm
prende un parametro d'ingresso obbligatorio
 l'elenco delle vm da rimuovere 
 
e procede eliminandolesia dall'inventory che dal datastore
esempio di utilizzo:
 .\remove_old_clone_only_by_name.ps1  -server dhet,getr  
#>

param ([Parameter(Mandatory)]$server)

$servername = @($server.split(","))

$machine_to_remove = @()

Foreach ($vm in $servername) {

$VM = $vm 

$machine_to_remove += $VM



}


write-host "Stai per procedere alla rimozione delle seguenti macchine:"

$machine_to_remove

$risposta = Read-host -Prompt "Rispondere yes per confermare"

if ($risposta -ne "yes") {Exit}


Foreach ($vm in $machine_to_remove) {



$VM = Get-vm -name $vm

$Output = Remove-VM -VM $VM -DeletePermanently -Confirm:$false

#$Output

if (-Not $Output) {write-host "Macchina $vm rimossa"}




}

