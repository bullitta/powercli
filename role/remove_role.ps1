<#Rimuovi un ruolo

prende 1 parametro d'ingresso obbligatorio
1 nome ruolo


esempio di lancio:
 .\remove-role.ps1 -roles ahht,ahytr

#>
param ([Parameter(Mandatory)]$roles)

$ruoli = @($roles.split(","))

Foreach ($rol in $ruoli) {

$ruolo = Get-VIRole -name $rol

if ($ruolo) {
           write-host ("Stai per rimuovere il ruolo $rol")
           $risposta = Read-host -Prompt "Rispondere yes per confermare"
           if ($risposta -ne "yes") {Exit}
           Remove-VIRole -role $ruolo -confirm:$false
           } else {write-host ("Ruolo $rol non trovato")}

}