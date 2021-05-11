<# Ricava l'elenco dei nomi di tutti i gruppi/utenti che compaiono in almeno un entitlement delle app




esempio di utilizzo

.\find-all-group-user-in-all-entitlements.ps1  

#>

# Ricavo il nome di tutte le applicazioni definite che salvo in $app_array

$allApp = get-hvapplication
$elenco = @()

# Ricavo l'elenco dei gruppi utilizzati per gli entitlement delle app

 Foreach ($app in $allApp) {


$ent =  get-hventitlement -resourcetype application -resourcename $app.data.name

if ($ent -ne '') {$elenco = $elenco + $ent.base.name}

}

# Ricavo l'elenco dei gruppi utilizzati per gli entitlement dei desktop pool
$allPool = get-hvpool

Foreach ($pool in $allPool) {


$ent =  get-hventitlement  -resourcename $pool.base.name

if ($ent -ne '') {$elenco = $elenco + $ent.base.name}

}

# elimino i duplicati

$elenco_new =  $elenco|sort -Unique
write-host "--------ELENCO GRUPPI E UTENTI----------"
$elenco_new
