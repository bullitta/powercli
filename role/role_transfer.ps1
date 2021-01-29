<# Trasferisce uno o più ruoli tra due vcenter

prende 3 parametri d'ingresso obbligatori
1 nome vcenter sorgente
2 nome vcenter destinazione
3 nome ruoli

esempio di lancio:
 .\role_transf.ps1 -source vcenter1 -destination vcenter2 roles ahht,ahytr

#>

param ([Parameter(Mandatory)]$source,[Parameter(Mandatory)]$destination,[Parameter(Mandatory)]$roles)

$ruoli = @($roles.split(","))

#Setta in multimode la configurazione di powercli e si collega ai due vcenter
set-powercliconfiguration -defaultviservermode multiple -confirm:$false
Connect-VIServer -server $source,$destination


Foreach ($rol in $ruoli) {
#lista privilegi role $rol
$listpriv = Get-VIPrivilege -role (get-virole -name $rol -server $source)
if ($listpriv) {
        #Creo un ruolo vuoto in nel server di destinazione
        New-VIRole -name $rol -server $destination
        Set-VIRole -role $rol -server $destination -addprivilege (Get-VIPrivilege -id $listpriv.id -server $destination)
                }
                 else{Write-Host ("Role $rol not found in $source")}
}

#Riporta in single mode la configurazione di powercli
set-powercliconfiguration -defaultviservermode single -confirm:$false