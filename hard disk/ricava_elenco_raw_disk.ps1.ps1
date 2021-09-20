<# ricava elenco raw disk assegnati ad una vm
   prende un parametro d'ingresso:
   nome della vm

   Esempio di lancio:
   .\ricava_elenco_raw_disk.ps1 -v namew
#>

param ([Parameter(Mandatory)]$vm)

$Rawdisk = GET-VM -name $vm |Get-HardDisk -DiskType "RawPhysical"|select Name,ScsiCanonicalName

$Rawdisk