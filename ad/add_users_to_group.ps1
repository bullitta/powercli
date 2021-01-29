<# Prende due parametro d'ingresso  obbligatori


nome dell'ad  group
elenco degli user

e aggiunge l'elenco degli utenti  al gruppo

esempio di utilizzo

.\add_users_to_group.ps1  -g "SAP logon" -u proi,dert

#>

param ([Parameter(Mandatory)]$group, [Parameter(Mandatory)]$users  )

$verifiedGroup = get-adgroup -filter 'name -like $group'

if (!$verifiedGroup) {Write-Host "Gruppo non presente su AD"

                       exit

                       }

 Foreach ($user in $users) {

 Add-ADGroupmember -Identity $verifiedGroup -Members $user -Confirm:$false
    

}             