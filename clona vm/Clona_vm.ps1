<# Prende due parametri d'ingresso tutti obbligatori

1) elenco nomi server separati da virgola
2) suffisso che si vuole dare al nome delle nuove macchine


Il datastore dove verrà depositato il clone verrà scelto mediante un procedimento automatico ripetuto per ogni macchina

ESEMPIO DI LANCIO

.\CLONA_VM.PS1 -server Pas87,cdert4e3 -suffix 06052020_patch 

#>

param ([Parameter(Mandatory)]$server,[Parameter(Mandatory)]$suffix)



$servername = @($server.split(","))


Foreach ($vm in $servername) {

#Ricavo il datastore da utilizzare per salvare la copia dei cloni
# seleziona i datastore con multipath visibili al cluster che non contengono BCK e REPL nel nome


$cluster = Get-cluster -vm $vm
$Datastore = $Cluster|get-datastore | where {$_.ExtensionData.Summary.MultipleHostAccess -eq 'true'}|sort-object -Property freespacegb -descending|select name

$valid_datastore = @()

$Datastore|foreach {if ($_ -NOTmatch "BCK" -and $_ -NOTMatch "REPL" -and $_ -NOTMatch "SRM" -and $_ -notmatch "library") {
                                                                     $name = @("$_".split('='))
                                                                     $nome = $name[1].Substring(0,$name[1].Length-1)
                                                                     $valid_datastore += "$nome"
                                                                     }
                       }

#Questa parte serve a bypassare il problema della presenza di nomi  duplicati dei datastore (stesso nome ma id diverso)
$dstoreid = @(get-datastore -name $valid_datastore[0])
$dstore = get-datastore -id $dstoreid[0].id




#Crea il clone

$vm_new = $vm + "_" + $suffix
$VM = GET-VM -name $vm

New-VM -name $vm_new -VM $VM -Datastore $dstore -ResourcePool $Cluster



   }


