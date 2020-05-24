<# Prende in ingresso tre parametri obbligatori:
 il nome del cluster
 il wwn della lun assegnare al nuovo datastore
il nome del storage da cui ricavare il nome del datastore da assegnare

esempio di lancio:
 
.\assegna_nuova_lun_a_nuovo_datastore.ps1 -cluster AP_Center -wwn 4590409 -storage EMC2



#>


param ([Parameter(Mandatory)]$cluster,[Parameter(Mandatory)]$wwn, [Parameter(Mandatory)]$storage)



#Scan su tutti gli host del cluster per individuare le nuove LUN


#GET-cluster -name $cluster|Get-VMHost|Get-VMhostStorage -RescanAllHba




#prende come riferimento il primo host del cluster per le operazioni di assegnazione

$VMhost = Get-cluster -name $cluster|Get-VMHost -name *esx*01*





#verifica se la LUN risulta già assegnata
$LUN = "naa." + $wwn
$AllDatastores = $VMhost|Get-datastore
foreach ($ds in $AllDatastores) {
                                 if ($ds.extensiondata.info.vmfs.extent.DiskName -eq $LUN) {
                                                        write-host "LUN già presente ed assegnata a $ds"
                                                        Exit
                                                                                           }
                                                              }
                        
   



#Ricavo il nome del datastore da creare in base alle convenzioni e lo scrivo in $ds_new_name

$ds = @(get-datastore -name $cluster*$storage|select-object name|SORT NAME)
$ds_name = $ds[$ds.count - 1].Name.ToString()
$prefix = ($cluster|measure-object -character).Characters
$suffix = ($storage|measure-object -character).Characters
$ds_name_length = ($ds_name|measure-object -character).Characters
$lun_1 = $ds_name.Substring($prefix,$ds_name_length - $prefix)
$lun_1_length = ($lun_1|measure-object -character).Characters
$lun_id = $lun_1.Substring(0,$lun_1_length - $suffix)
$num_lun = $lun_id -replace '\D+(\d+)\D','$1'
$num_lun = [int]$num_lun + 1
$num_lun = "0" + "$num_lun"
$ds_new_name = $cluster +"_LUN" + $num_lun + "_" + $storage

<#
# Creo il nuovo datastore e gli assegno la nuova lun

New-datastore -Vmfs -VMhost $VMhost -Name $ds_new_name -Path $LUN

#>