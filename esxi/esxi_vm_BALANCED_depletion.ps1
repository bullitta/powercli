<#
  Lo SCRIPT serve a svuotare completamente un esxi dalle vm
  spostandole  DISTRIBUENDOLE SUGLI esxi  dello stesso cluster
  Prende come parametrO d'ingresso l'esxi CHE deve essere svuotato

  Esempio di utilizzo
  .\esxi_vm_BALANCED_depletion.ps1 -server esx1  


#>

param ([Parameter(Mandatory)]$server )

$Cluster = get-cluster -vmhost $server
$vms_name = get-vmhost -name $server|get-vm |select-object name

foreach ($vm in $vms_name) {

     ##...Calcola l'host di destinazione individuando quello con minor CPU e mem utilizzata

        $VMhost = $Cluster|get-vmhost|where ConnectionState -eq "Connected"|sort CpuUsageMhz, MemoryUsageGB
        
     ##... Sposta la vm
         get-vm -name $vm|Move-VM -Destination $VMhost[0] 

}
