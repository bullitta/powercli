<# Prende in ingresso tre parametri obbligatori:
 il nome del cluster
 il wwn della lun assegnare al nuovo datastore
il nome del datastore

esempio di lancio:
 
.\assegna_nuova_lun_a_nuovo_datastore_nome_predefinito.ps1 -cluster AP_Center -wwn 4590409 -datastore EMC2



#>


param ([Parameter(Mandatory)]$cluster,[Parameter(Mandatory)]$wwn, [Parameter(Mandatory)]$datastore)

##..Pulizia del nome lun: rimuovi i ":" se presenti

$wwn = $wwn -replace ':',''





##..Scan su tutti gli host del cluster per individuare le nuove LUN

GET-cluster -name $cluster|Get-VMHost|Get-VMhostStorage -RescanAllHba




##..prende come riferimento il primo host del cluster per le operazioni di assegnazione

$VMhost = Get-cluster -name $cluster|Get-VMHost -name *01*





##..verifica se la LUN risulta già assegnata
$LUN = "naa." + $wwn
$AllDatastores = $VMhost|Get-datastore
foreach ($ds in $AllDatastores) {
                                 if ($ds.extensiondata.info.vmfs.extent.DiskName -eq $LUN) {
                                                        write-host "LUN già presente ed assegnata a $ds"
                                                        Exit
                                                                                           }
                                                              }
                        
   




##... Creo il nuovo datastore e gli assegno la nuova lun

New-datastore -Vmfs -VMhost $VMhost -Name $datastore -Path $LUN

