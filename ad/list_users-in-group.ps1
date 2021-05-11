<# Prende un parametro d'ingresso  obbligatorio


nome dell'ad  group
e genera l'elenco degli utenti che appartengono al gruppo

esempio di utilizzo

.\list-users-in-group  -g "SAP logon"

#>

param ([Parameter(Mandatory)]$group )

$verifiedGroup = get-adgroup -filter 'name -like $group'

if (!$verifiedGroup) {Write-Host "Gruppo non presente su AD"

                       exit

                       }

                       get-adgroupmember -identity $verifiedGroup|Select -ExpandProperty Name