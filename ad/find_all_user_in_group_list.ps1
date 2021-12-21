<# Prende un parametro d'ingresso  obbligatorio


elenco degli ad  group
e genera l'elenco degli utenti che appartengono ai vari gruppi

esempio di utilizzo

.\find_all_user_in_group_list.ps1  -g "SAP logon", "msql logon"


NOTE: si combina bene con lo script ..\horizon1\find-all-group-user-in-all-entitlements.ps1
che serve a trovare l'elenco di tutti i gruppi presenti nei vari entitlement
#>



param ([Parameter(Mandatory)]$grouplist )

$elenco = @()

Foreach ($group in $grouplist) {

$verifiedGroup = get-adgroup -filter 'name -like $group'

if (!$verifiedGroup) {Write-Host "Gruppo $group non presente su AD"

                       exit

                       }

                   $elenco =  $elenco + ( get-adgroupmember -identity $verifiedGroup|Select -ExpandProperty Name)

}

$elenco_new = $elenco |sort -Unique

$elenco_new
write-host "Utenti totali abilitati:" 
$elenco_new.length
