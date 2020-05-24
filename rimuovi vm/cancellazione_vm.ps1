<#
Prende un unico parametro d'ingresso l'elenco delle vm da rimuovere
Esempio di lancio

.\cancellazione_vm.ps1  prpio,asrt1


#>

param ([Parameter(Mandatory)]$server)

$servername = @($server.split(","))


write-host "Stai per procedere alla cancellaione delle seguenti vm:"
write-host $servername
$risposta = Read-host -Prompt "Rispondere yes per confermare"

if ($risposta -ne "yes") {Exit}

Foreach ($vm in $servername) {


$VM = Get-vm -name $vm

If ($VM.PowerState -eq "PoweredOn")  {Stop-vm -VM $vm -Confirm:$false}

Remove-VM -VM $VM -DeletePermanently -Confirm:$false


write-host "$vm cancellata"

}





