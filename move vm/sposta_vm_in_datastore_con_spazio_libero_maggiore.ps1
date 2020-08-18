<# Sposta le vm in un datastore di destinazione

prende un parametr0 d'ingresso:

elenco vm


esempio di utilizzo

.\sposta_vm_in_datastore_con_spazio_libero_maggiore.ps1 -s aktre,poer93 
#>

param ([Parameter(Mandatory)]$server)

$servername = @($server.split(","))

Foreach ($vm in $servername) {



#Ricavo il datastore da utilizzare 
# seleziona i datastore con multipath visibili al cluster che non contengono BCK, REPL, ....nel nome


$cluster = Get-cluster -vm $vm
$Datastore = $Cluster|get-datastore | where {$_.ExtensionData.Summary.MultipleHostAccess -eq 'true'}|sort-object -Property freespacegb -descending|select name

$valid_datastore = @()

$Datastore|foreach {if ($_ -NOTmatch "BCK" -and $_ -NOTMatch "REPL" -and $_ -NOTMatch "SRM" -and $_ -notmatch "library" -and $_ -notmatch "NAS") {
                                                                     $name = @("$_".split('='))
                                                                     $nome = $name[1].Substring(0,$name[1].Length-1)
                                                                     $valid_datastore += "$nome"
                                                                     }
                       }

#Questa parte serve a bypassare il problema della presenza di nomi  duplicati dei datastore (stesso nome ma id diverso)
$dstoreid = @($Cluster|get-datastore -name $valid_datastore[0])
$dstore = get-datastore -id $dstoreid[0].id










$VM = GET-VM -name $vm

Move-VM -VM $VM -Datastore $dstore

}