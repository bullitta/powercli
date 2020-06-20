<# prende tre parametri d'ingresso

lista vm 
nome hard disk in genere è del tipo "Hard Disk 1"
size in gb dell'estenzione

E calcola ed assegna la nuova dimesione  al disco

esempio di utilizzo:

.\estendi_hdisk_vm.ps1 -server arte1,arte2 -disk "Hard Disk 1" -size 10


#>

param ([Parameter(Mandatory)]$server, [Parameter(Mandatory)]$disk,[Parameter(Mandatory)]$size )


$servername = @($server.split(","))


Foreach ($vm in $servername) {

$VM = get-vm -name $vm

$Hdisk = $VM|get-Harddisk|where-object {$_.Name -eq $disk}

$size = $size + $Hdisk.CapacityGb



set-harddisk -Harddisk $Hdisk -CapacityGB $size -Confirm:$false



}
