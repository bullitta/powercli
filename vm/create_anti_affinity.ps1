<# prende due parametri d'ingresso

1 nome anti-affinity rule
2 elenco vm cui applicare l'anti-affinity rule

esempio di utilizzo

.\create_anti_affinity.ps1 -name sgst -vm ahhy,ajju

#>

param ([Parameter(Mandatory)]$name,[Parameter(Mandatory)]$vm)



$cluster = Get-Cluster -vm (Get-VM -name $vm)
if (-not $cluster) {
                  Write-Host ("Le macchine non risiedono sullo stesso cluster")
                  Write-Host ("impossibile creare l'anti-affinity rule")
                  Exit
                   }




New-DrsRule -cluster $cluster -name $name -KeepTogether $false -VM $vm



