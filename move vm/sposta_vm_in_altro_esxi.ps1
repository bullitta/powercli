<# Sposta le vm in un altro host sempre dello stesso cluster

prende due parametri d'ingresso:

elenco vm
host di destinazione

esempio di utilizzo

.\sposta_vm_in_altro_datastore.ps1 -s aktre,poer93 -host esxi1
#>

param ([Parameter(Mandatory)]$server,[Parameter(Mandatory)]$esxi)


$servername = @($server.split(","))


Foreach ($vm in $servername) {

$VM = GET-VM -name $vm

Move-VM -VM $VM -Destination $esxi

}