<# Ricava l'elenco dei nomi di tutti i gruppi/utenti che compaiono in almeno un entitlement delle app




esempio di utilizzo

.\find-all-group-user-in-entitlements.ps1  

#>

# Ricavo il nome di tutte le applicazioni definite che salvo in $app_array

$allApp = get-hvapplication
$elenco = @()

Foreach ($app in $allApp) {


$ent =  get-hventitlement -resourcetype application -resourcename $app.data.name

if ($ent -ne '') {$elenco = $elenco + $ent.base.name}

}
# elimino i duplicati

$elenco_new =  $elenco|sort -Unique
write-host "--------ELENCO GRUPPI E UTENTI----------"
$elenco_new