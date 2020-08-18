<# verifica la visibilità delle lun assegnate ad un cluster esx
   prende due parametri d'ingresso:
   elenco delle lun assegnate al cluster
   nome del cluster
   Esempio di lancio:
   .\verifica_vis_LUN.ps1 -wwn 60:00:09...,09:0a:b1... -cluster Pmob_q
#>

param ([Parameter(Mandatory)]$wwn,[Parameter(Mandatory)]$cluster)

##..Pulizia del nome lun: rimuovi i ":" se presenti

$wwn = $wwn -replace ':',''


#Scan su tutti gli host del cluster per individuare le nuove LUN

GET-cluster -name $cluster|Get-VMHost|Get-VMhostStorage -RescanAllHba


$EsxiHost = GET-cluster -name $cluster|Get-VMHost

$lun = @($wwn.split(","))


#$EsxiHost|format-list *



##... Verifico la visibilità di ogni wwn su ogni host

Foreach ($esxi in $EsxiHost) {
                              foreach ($lunid in $lun) {
                                         $lunid = "naa." + "$lunid"
                                        if ($esxi|get-scsilun -canonicalname $lunid) {
                                                             write-host "Lun $lunid presente su $esxi" }
                                                        else {write-host "Lun $lunid non presente su $esxi"}
                                         
                                                        }

                             }

