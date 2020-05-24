<# Rimuovi in maniera permanente un insieme di vm
prende due parametr d'ingresso entrambi obbligatori
 l'elenco delle vm da rimuovere 
  il suffisso utilizzato per individuare i cloni
e procede eliminandolesia dall'inventory che dal datastore
esempio di utilizzo:
 .\remove_old_clone.ps1  -server dhet,getr  -suffix 2013_01
#>

param ([Parameter(Mandatory)]$server,[Parameter(Mandatory)]$suffix)

$servername = @($server.split(","))

$machine_to_remove = @()

Foreach ($vm in $servername) {

$VM = $vm + $suffix

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

