<# Lo script crea una nuova vm e monta un file iso 
   Prende tre  parametri d'ingresso:
   Il nome della vm
   Il nome del cluster in cui si vuole creare la vm
   Il nome del file iso
   Esempio di lancio:
   .\create_vm_from_scratch.ps1 -server vm1 -cluster Clu -iso yubutu.iso
#>

param ([Parameter(Mandatory)]$server, [Parameter(Mandatory)]$cluster, [Parameter(Mandatory)]$iso )

New-VM -Name $server -ResourcePool $cluster




