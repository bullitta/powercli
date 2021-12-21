<# Lo script  
Prende tre parametri d'ingresso: 
 nome della vm
 nome da associare allo snapshot
 descrizione dello snapshot

 E crea un nuovo snapshot della vm

 Esempio di utilizzo

 .\create_new_snapshot.ps1 -s vm1 -n snapshot1 -d "primo snapshot"

#>

param ([Parameter(Mandatory)]$server,[Parameter(Mandatory)]$name,[Parameter(Mandatory)]$description)

$vm = get-vm -name $server

new-snapshot -vm $vm -name $name -description $description