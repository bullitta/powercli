<# Prende due parametro d'ingresso  obbligatori


elenco  degli ad  group
nome dell'user

e verifica se l'user  è presente o meno nei gruppi

esempio di utilizzo

.\verify-users-in-group.ps1  -g "SAP logon","ser"  -u bill
ATTENZIONE NON FUNZIONA NEL CASO IN CUI AL GRUPPO SIANO STATE AGGIUNTE UTENZE CHE NON FANNO PARTE DEL DOMINIO RETE.POSTE
#>

param ([Parameter(Mandatory)]$group, [Parameter(Mandatory)]$user )

Foreach ($vgroup in $group) {

$verifiedGroup = get-adgroup -filter 'name -like $vgroup'

if (!$verifiedGroup) {Write-Host "Gruppo non presente su AD"

                       exit

                       }

}


$verifieduser = get-aduser -filter 'name -like $user'


if (!$verifiedUser) {Write-Host "User non presente su AD"

                       exit

                       }

Foreach ($vgroup in $group) {

 $members =    get-adgroupmember -identity $vgroup|Select -ExpandProperty Name

  if ($members -contains $user) {$vgroup
                                 Write-Host "$user exists in group $vgroup"
                                       }
      else {
                                 Write-Host "$user not exists in group $vgroup"
                                       }

}




