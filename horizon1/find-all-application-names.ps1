<# Ricava l'elenco dei nomi di tutte le applicazioni definite sulle varie farm




esempio di utilizzo

.\find-all-applications-names.ps1  

#>

$allApp = get-hvapplication


Foreach ($app in $allApp) {

Write-Host ($app.data.name)

}
