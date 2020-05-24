<# Prende due parametri d'ingresso entrambi obbligatori

elenco nomi vm
nome del folder

e sposta tutte le macchine dell'elenco nel folder

esempio di utilizzo

.\move_vm_in_folder.ps1 -server stert,dtree -folder MailMx

#>

param ([Parameter(Mandatory)]$server,[Parameter(Mandatory)]$folder)

$servername = @($server.split(","))

$dir = Get-Folder -Name $folder

$dir



Foreach ($vm in $servername) {

$VirtM = get-vm -name $vm

$VirtM| Move-VM -Destination $dir

}
