<#
   Serve per spostare da un datastore ad un altro una serie di template
   Prende due parametri d'ingresso
   1) elenco dei template da spostare
   2) nome del datastore di destinazione
   esempio di utilizzo:
   .\cambia_datasore.ps1 -server ase,asw,idi -datastore ALL_DATA
#>


param ([Parameter(Mandatory)]$server,[Parameter(Mandatory)]$datastore)

$servername = @($server.split(","))
Foreach ($vm in $servername) {
    $VMachine = set-template -template $vm -ToVM -confirm:$false
    Move-VM -VM $VMachine -datastore $datastore
    Set-VM -VM $VMachine -ToTemplate -confirm:$false

}