<# Sposta le vm in un datastore di destinazione assegnato d un Esxi

prende due parametri d'ingresso:

elenco vm
suffisso 

e agisce spostando creando i cloni  delle vm chiamati con vm_suffisso e sistemandoli in uno degli  storage locali degli esxi

esempio di utilizzo

.\crea_clone_vm_in_datastore_locale.ps1 -server aktre,poer93 -suffix backup
#>

param ([Parameter(Mandatory)]$server, [Parameter(Mandatory)]$suffix)

$servername = @($server.split(","))


Foreach ($vm in $servername) {

$vm_new = $vm + "_" + "$suffix"

$cluster = get-cluster -vm $server

#Ricavo il local dstore con maggiore spazio

$dstoreloc = @($cluster|get-datastore -name *local*|sort-object -Property freespacegb -descending)



#Ricavo il nome dell'host in cui si trova lo storage locale
$esxi_name = @($dstoreloc[0].name.split("_"))
$esxi = $esxi_name[1]
$esxi = "*" + "$esxi" + "*"
$VMhost = get-VMhost -name $esxi




#Creo il clone della vm nel datastore locale

new-vm -name $vm_new -VM $vm -Datastore $dstoreloc[0] -VMhost $VMhost

}