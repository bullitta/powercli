<# Prende in ingresso due parametri obbligatori:
 il nome del cluster
 il wwn della lun da analizzare

 e ricava il datastore a cui è stata assegnata una lun
esempio di lancio:
 
.\ricava_assegnazione_lun_a_datastore.ps1 -cluster AP_Center -wwn naa.4590409 



#>

param ([Parameter(Mandatory)]$cluster,[Parameter(Mandatory)]$wwn)


#prende come riferimento il primo host del cluster per le operazioni di verifica

$VMhost = Get-cluster -name $cluster|Get-VMHost -name *01*


#Identifica il nome del datastore cui la  LUN è stata assegnata

$AllDatastores = $VMhost|Get-datastore
foreach ($ds in $AllDatastores) {
                                 if ($ds.extensiondata.info.vmfs.extent.DiskName -eq $wwn) {
                                                        write-host "LUN  assegnata a $ds"
                                                        Exit
                                                                                           }
                                                              }
                        
#Ricava le vm che adoperano il datastore individuato

