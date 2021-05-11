<# Ricava l'elenco di marca e modello delle hba online  degli host esxi presenti in un cluster


Richiede un unico parametro d'ingresso

nome del cluster

esempio di utilizzo

.\find-all-hba-model-in-cluster-esxi.ps1  -c cluster2

#>

param ([Parameter(Mandatory)]$cluster )

#Ricava i nomi degli host appartenenti al cluster

$vmhost = get-vmhost -Location $cluster


foreach ($vhost in $vmhost) {

$hba = get-vmhosthba -vmhost $esxi1 -type FibreChannel |where {$_.status -eq "online"} 
write-host ($vhost)
write-host ($hba.model)

}