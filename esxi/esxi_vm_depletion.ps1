<#
  Lo SCRIPT serve a svuotare completamente un esxi dalle vm
  spostandole  in un altro esxi sempre dello stesso cluster
  Prende come parametri d'ingresso l'esxi sorgente e quello di destinazione

  Esempio di utilizzo
  .\esxi_vm_depletion.psi -source esx1  -dest esx2


#>

param ([Parameter(Mandatory)]$source, [Parameter(Mandatory)]$dest )


$vms_name = get-vmhost -name $source|get-vm |select-object name

foreach ($vm in $vms_name) {

          get-vm -name $vm|Move-VM -Destination $dest 

}
