<# prende come parametro d'ingresso l'elenco delle vm 
spegne le vm e toglie l'assegnazione di tutti i dischi a meno del primo
lo script produce in automatico i comandi per la riassegnazione dei dischi che salva nello script

riassegna_hdisk_to_vm.ps1

Esempio di lancio:

.\togli_hdisk_a_vm_tranne_il_primo.ps1 -server poiu,astsr

#>

param ([Parameter(Mandatory)]$server)

New-item -Path .  -Name "riassegna_hdisk_to_vm.ps1" -Force



$servername = @($server.split(","))



Foreach ($vm in $servername) {

$VM = get-vm -name $vm

#Crea elenco dischi della vm ed esclude il primo

$Hdisk = @($VM|get-harddisk)

$first,$dischi_da_rimuovere = $Hdisk




write-host "Si sta per de-assegnare i seg. dischi alla vm $vm"



$dischi_da_rimuovere|foreach {write-host " name: "$_.name", diskPath: "$_.Filename""}



$risposta = Read-host -Prompt "Rispondere yes per confermare"

if ($risposta -ne "yes") {Exit}

#fermo la vm
Stop-vm -VM $vm -Confirm:$false

#Rimuovo i dischi
$dischi_da_rimuovere|Foreach { get-harddisk -Id $_.id -VM $VM|Remove-Harddisk -Confirm:$false}

#Creo lo script per la riassegnazione dei dischi
write-host "lo script per la ri-assegnazione dei dischi si trova in questa cartella e si chiama riassegna_hdisk_to_vm.ps1:"

$dischi_da_rimuovere|foreach {Add-content riassegna_hdisk_to_vm.ps1 "get-vm -name $vm|new-harddisk -DiskPath '$($_.filename)' "}

}
