<# Prende due parametro d'ingresso  obbligatori


nome dell'ad  group
elenco degli user

e toglie l'elenco degli utenti  dal gruppo

esempio di utilizzo

.\remove_user_from_group.ps1  -g "SAP logon" -u proi,dert

#>

param ([Parameter(Mandatory)]$group, [Parameter(Mandatory)]$users  )

$verifiedGroup = get-adgroup -filter 'name -like $group'

if (!$verifiedGroup) {Write-Host "Gruppo non presente su AD"

                       exit 

                       }

 Foreach ($user in $users) {

 Remove-ADGroupmember -Identity $verifiedGroup -Members $user -Confirm:$false
    

}   