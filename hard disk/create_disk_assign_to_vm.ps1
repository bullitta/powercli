<#
   Crea un nuovo hd e lo assegna ad una vm
   Prende tre parametri d'ingresso
   Nome della vm
   Nome del datastore in cui si trova lo spazio disco
   Estensione in Gb del disco
   Esmpio di lancio
   .\create_disk_assign_to_vm.ps1 -server sgsgt -dstore sgsgsg -gb 


#>

param ([Parameter(Mandatory)]$server,[Parameter(Mandatory)]$dstore,[Parameter(Mandatory)]$gb )


$Datast = get-datastore -name $dstore


New-HardDisk -VM $server -Datastore $Datast -CapacityGB $gb