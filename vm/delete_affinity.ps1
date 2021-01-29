<# prende un parametro d'ingresso

 nome (anti-)affinity rule

 ed elimina la regola di affinity (o anti-affinity) dal gruppo di vm
esempio di utilizzo

.\delete_affinity.ps1 -name sgst 
#>

param ([Parameter(Mandatory)]$name)

$rule = Get-DrsRule -name $name -cluster (get-cluster)

if (-not $rule ) { 
                  Write-Host ("Regola di affinity non presente, verificare")
                  exit
                   }

Remove-DrsRule -rule $rule -confirm:$false