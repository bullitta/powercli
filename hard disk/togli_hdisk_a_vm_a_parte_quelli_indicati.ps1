<# prende due parametri d'ingresso
1) l'elenco delle vm 
2) l'elenco dei dischi che non devono essere deassegnati
spegne le vm e toglie l'assegnazione di tutti i dischi a meno di quelli assegnati
lo script produce in automatico i comandi per la riassegnazione dei dischi che salva nello script

riassegna_hdisk_to_vm.ps1

Esempio di lancio:

.\togli_hdisk_a_vm_a_parte_quelli_indicati.ps1 -server poiu,astsr -disk "Hard disk1","Hard disk 2"

Not:
 in genere i dischi dove sta il sistema operativo sono i primi assegnati alla macchina ma per essere
sicuri è necessario accedere e fare una verifica
Inoltre questi primi due dischi si chiamano "Hard disk 1" e "Hard disk 2"

#>

param ([Parameter(Mandatory)]$server,[Parameter(Mandatory)]$disk)







$servername = @($server.split(","))
$system_disk = @($disk.split(","))



Foreach ($vm in $servername) {

#crea il file dove verranno salvati i comandi per la riassegnazione dei dischi rimuovendo eventuali script
#con lo stesso nome già presenti


New-item -Path .  -Name "riassegna_hdisk_to_vm_$vm.ps1" -Force |Out-null

$VM = get-vm -name $vm

#Crea elenco dei dischi della vm da de-assegnare e li mette nell'array $Hdisk

$Hdisk_all = @($VM|get-harddisk)

foreach ($hd in $system_disk) {
                  $Hdisk_all = $Hdisk_all|where-Object {$_.name -ne  $hd} 
                  $dischi_da_rimuovere = $Hdisk_all 
                  
                  }






write-host "Si sta per de-assegnare i seg. dischi alla vm $vm"



$dischi_da_rimuovere|foreach {write-host " name: "$_.name", diskPath: "$_.Filename""}



$risposta = Read-host -Prompt "Rispondere yes per confermare"

if ($risposta -ne "yes") {Exit}



#fermo la vm
#Stop-vm -VM $vm -Confirm:$false

#Rimuovo i dischi
$dischi_da_rimuovere|Foreach { get-harddisk -Id $_.id -VM $VM|Remove-Harddisk -Confirm:$false}

#Creo lo script per la riassegnazione dei dischi
write-host "lo script per la ri-assegnazione dei dischi si trova in questa cartella e si chiama riassegna_hdisk_to_vm_$vm.ps1:"

$dischi_da_rimuovere|foreach {Add-content riassegna_hdisk_to_vm_$vm.ps1 "get-vm -name $vm|new-harddisk -DiskPath '$($_.filename)' "}


}
