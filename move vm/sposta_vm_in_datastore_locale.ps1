<# Sposta le vm in un datastore di destinazione assegnato d un Esxi

prende un parametro d'ingresso:

elenco vm

e agisce spostando i clone (spento) delle vm in uno degli  storage locali degli esxi

esempio di utilizzo

.\sposta_vm_in_datastore_locale.ps1 -s aktre,poer93 
#>

param ([Parameter(Mandatory)]$server)

$servername = @($server.split(","))


Foreach ($vm in $servername) {


$cluster = get-cluster -vm $server

#Ricavo il local dstore con maggiore spazio

$dstoreloc = @($cluster|get-datastore -name *local*|sort-object -Property freespacegb -descending)



#Ricavo il nome dell'host in cui si trova lo storage locale
$esxi_name = @($dstoreloc[0].name.split("_"))
$esxi = $esxi_name[1]
$esxi = "*" + "$esxi" + "*"
$VMhost = get-VMhost -name $esxi




#Sposto la vm nel datastore locale

move-vm -VM $vm -Datastore $dstoreloc[0] -Destination $VMhost

}