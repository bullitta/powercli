<# Prende due parametri d'ingresso, obbligatori:

1) elenco nomi server separati da virgola
2) suffisso che si vuole dare al nome delle nuove macchine


Il datastore dove verrà depositato il clone verrà scelto mediante un procedimento automatico ripetuto per ogni macchina

ESEMPIO DI LANCIO

.\CLONA_VM.PS1 -server Pas87,cdert4e3 -suffix 06052020_229

#>

param ([Parameter(Mandatory)]$server,[Parameter(Mandatory)]$suffix)



$servername = @($server.split(","))


Foreach ($vm in $servername) {

#Ricavo il datastore da utilizzare per salvare la copia dei cloni
# seleziona i datastore con multipath visibili al cluster che non contengono BCK e REPL nel nome


$cluster = Get-cluster -vm $vm
$Datastore = $Cluster|get-datastore | where {$_.ExtensionData.Summary.MultipleHostAccess -eq 'true'}|sort-object -Property freespacegb -descending|select name

$valid_datastore = @()

$Datastore|foreach {if ($_ -NOTmatch "BCK" -and $_ -NOTMatch "REPL" -and $_ -NOTMatch "SRM" ) {
                                                                     $name = @("$_".split('='))
                                                                     $nome = $name[1].Substring(0,$name[1].Length-1)
                                                                     $valid_datastore += "$nome"
                                                                     }
                       }

#$valid_datastore


#Crea il clone

$vm_new = $vm + "_" + $suffix
$VM = GET-VM -name $vm

New-VM -name $vm_new -VM $VM -Datastore $valid_datastore[0] -ResourcePool $Cluster


   }


