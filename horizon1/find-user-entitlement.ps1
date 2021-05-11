<# Prende un parametro d'ingresso  obbligatorio


nome dell' user ad 

e genera un elenco di tutte le applicazioni che hanno quell'user nell'entitlement

esempio di utilizzo

.\find-user-entitlement.ps1  -u proi

#>

param ([Parameter(Mandatory)]$user )


$verifieduser = get-aduser -filter 'name -like $user'


if (!$verifiedUser) {Write-Host "User non presente su AD"

                       exit

                       }


# Ricavo il nome di tutte le applicazioni definite che salvo in $app_array

$allApp = get-hvapplication
$elenco = @()



Foreach ($app in $allApp) {
# introduco l'ignore degli errori perchè sono presenti molte app prive di entitlement
$ErrorActionPreference = 'silentlycontinue'

$ent =  get-hventitlement -resourcetype application -resourcename $app.data.name

if ($ent.base.name -eq $user) {
                     $message = "entitlment in app: " + $app.data.name + " found for user: " + $user
                     $elenco = $elenco + $message
                     }
}
$elenco
# VERIFICO la presenza dell'user su un ad domain che sta in un entitlement


