<# Sposta le vm in un datastore di destinazione

prende due parametri d'ingresso:

elenco vm
datastore di destinazione

esempio di utilizzo

.\sposta_vm_in_altro_datastore.ps1 -s aktre,poer93 -d DISCO_F
#>

param ([Parameter(Mandatory)]$server,[Parameter(Mandatory)]$dstore)

# verifica che il datastore esista 

$DS = get-datastore -name $dstore

if (-not $DS) {write-host "Verificare il nome del datastore"
               Exit}

$servername = @($server.split(","))


Foreach ($vm in $servername) {

$VM = GET-VM -name $vm

Move-VM -VM $VM -Datastore $DS

}