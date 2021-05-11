<# Ricava l'elenco dei nomi di tutti i gruppi

prende un unico parametro d'ingresso:

nome dell'user su cui viene eseguita la verifica

esempio di utilizzo

.\find-all-entitlements-for-user.ps1  -u poiu

#>

param ([Parameter(Mandatory)]$user )


$verifieduser = get-aduser -filter 'name -like $user'


if (!$verifiedUser) {Write-Host "User non presente su AD"

                       exit

                       }

# Ricavo il nome di tutte le applicazioni definite che salvo in $allApp

$allApp = get-hvapplication
$elenco = @()

#Ricavo l'elenco di tutti i gruppi e utenti a cui è stato attribuito almeno un entitlement e salvo in 

Foreach ($app in $allApp) {


$ent =  get-hventitlement -resourcetype application -resourcename $app.data.name

$elenco = $elenco + $ent.base.name

}
# elimino i duplicati

$Allentitlement =  $elenco|sort -Unique

#  verifico la presenza dell'user nei gruppi estratti

$AssociatedGroup = @()

 Foreach ($group in $Allentitlement) {

 $members =    get-adgroupmember -identity $group|Select -ExpandProperty Name

  if ($members -contains $user) {
                                 $AssociatedGroup = $AssociatedGroup + $group
                                       }



}  


 

  

  