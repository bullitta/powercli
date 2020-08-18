<# 
   questo script importa le vm predisposte su sviluppo per il test VA

   Prende quattro parametri d'ingresso tutti obbligatori
   1) elenco template da esportare
   2) versione baseline
   3) versione hardening
   4) nome del cluster in cui importare il template

   esempio di utilizzo:

   .\Import_template.ps1 -s WIN2012,WIN2012-ORACLEDB121,RHEL76 -b 2020_T1 -h 2020_1

   NOTA: a differenza di IMPORt_Template.ps1 presente in questa stessa directory lo script presuppone che 
   non sia presente sul datacenter il template originale da sostituire, e per questo motivo richiede come
   parametro aggiuntivo il nome del cluster

#>

param ([Parameter(Mandatory)]$server,[Parameter(Mandatory)]$baseline,[Parameter(Mandatory)]$hardening, [Parameter(Mandatory)]$cluster)

# mi collego alla share dei template

New-PSDrive -Name Z -PSProvider FileSystem -Root \\dcpt000s020\CC_VMWARE\PrivateCloud\Templates 

if (-not (get-psdrive -literalname z)) {
                                        write-host  "impossibile collegarsi alla share contenente i template"
                                        write-host "Risolvere il problema prima di continuare"
                                        exit 
                                        }



$servername = @($server.split(","))

#Imposto alcune variabili che mi serviranno per l'import, uno anche per lo spostamento della macchina
#nel folder Templates ($Folder)




$Folder = Get-Folder -Name Templates


z:
# verifico la correttezza del nome cluster
if (-not (get-cluster -name $cluster)) {
                   write-host "Problema nell'identificazione del cluster"
                   Write-Host "Verificare il corretto inserimento dell'ultimo parametro prima di proseguire"
                   exit
                   }

$Cluster = get-cluster -name $cluster

Foreach ($vm in $servername) {
#Determino l'host in cui si deve creare il template
$vmhost_list = @(Get-Cluster -name $cluster|get-vmhost)
$VMHOST = $vmhost_list[0]






#Ricavo il nome di un port group da utilizzare per l'import
$vdswitch = get-vdswitch -vmhost $VMHOST
$All_PORTGROUP = Get-VDPortgroup -vDSWITCH $vdswitch
$PORTGROUP = $All_PORTGROUP[0]





#Ricavo il datastore da utilizzare per salvare il template
# seleziona i datastore con multipath visibili al cluster che non contengono BCK e REPL e altri #suffissi nel nome



$Datastore = $Cluster|get-datastore | where {$_.ExtensionData.Summary.MultipleHostAccess -eq 'true'}|sort-object -Property freespacegb -descending|select name

$valid_datastore = @()

$Datastore|foreach {if ($_ -NOTmatch "BCK" -and $_ -NOTMatch "REPL" -and $_ -NOTMatch "SRM" -and $_ -notmatch "library" -and $_ -notmatch "NAS" -and $_ -notmatch "VOIP" -and $_ -notmatch "GENESYS" -and $_ -notmatch "NFS" -and $_ -notmatch "OPSH") {
                                                                     $name = @("$_".split('='))
                                                                     $nome = $name[1].Substring(0,$name[1].Length-1)
                                                                     $valid_datastore += "$nome"
                                                                     }
                       }

#Questa parte serve a bypassare il problema della presenza di nomi  duplicati dei datastore (stesso nome ma id diverso)
$dstoreid = @($Cluster|get-datastore -name $valid_datastore[0])
$DATASTORE = get-datastore -id $dstoreid[0].id


$vm_new = $vm + "_" + "$baseline"
$dir= $vm.SubString(0,3)
if ($dir -eq "RHE") {$dir = "RHEL"}
if ($dir -eq "SLE") {$dir = "SUSE"}





$ovffile = $vm_new + ".ovf"
$OvfConfiguration = Get-OvfConfiguration -Ovf "$dir\CURRENT\$vm\$ovffile"


#IMPOSTA il networkmapping dell'oggetto $OvfConfiguration

$ovfConfiguration.ToHashTable()
    $ovfConfiguration = @{
       "NetworkMapping.DPortGroup"="$PORTGROUP";
       "Source"="$dir\CURRENT\$vm\$ovffile"
        }




#Importa la virtual machine


$Parameters = @{Source = "$dir\CURRENT\$vm\$ovffile"
 OvfConfiguration = $OvfConfiguration 
Name =  $vm_new
 DiskStorageFormat = 'Thin' 
vMHost = $VMHOST
Datastore = $DATASTORE
}





Import-Vapp @Parameters


$VirtM = Get-VM -name $vm_new



#Imposta i parametri di rete sulla vm importata

$VirtM |Get-NetworkAdapter|Set-NetworkAdapter -NetworkName $PORTGROUP -Confirm:$false



#Imposta i custom attribute in base al nome della macchina



$Array_vm = @($vm.Split("-"))

    If ($Array_vm.LENGTH -eq 1) {$Array_vm = @($vm.Split('_'))}

    if ($Array_vm[1] -eq "OWEBL121") {$Array_vm[1] = "ORACLE  WEBLOGIC"}
    if ($Array_vm[1] -eq "APACHE24") {$Array_vm[1] = "APACHE HTTPD SERVER 2.4"}
    if ($Array_vm[1] -eq "JBOSS71") {$Array_vm[1] = "JBOSS"}
    if ($Array_vm[1] -eq "MYSQL") {$Array_vm[1] = "MYSQL DATABASE 5.7.25"}
    if ($Array_vm[1] -eq "OHTTP") {$Array_vm[1] = "ORACLE HTTP"}
    if ($Array_vm[1] -eq "ORACLEDB121") {$Array_vm[1] = "ORACLE DATABASE 12C R2"}
    if ($Array_vm[1] -eq "ORACLEDB184") {$Array_vm[1] = "ORACLE DATABASE 18C"}
    if ($Array_vm[1] -eq "MIDDL") {$Array_vm[1] = "MICROSOFT IIS 10;MICROSOFT .NET FRAMEWORK 4.7.2"}
    if ($Array_vm[1] -eq "SQL2016") {$Array_vm[1] = "MICROSOFT SQL SERVER DATABASE 2016"}
    if ($Array_vm[1] -eq "SQL2017") {$Array_vm[1] = "MICROSOFT SQL SERVER DATABASE 2017"}
    if ($Array_vm[1] -eq "SQL2017EE") {$Array_vm[1] = "SQL SERVER DATABASE 2017 EE"}
    if ($Array_vm[1] -eq "SQL2017STD") {$Array_vm[1] = "SQL SERVER DATABASE 2017 STD"}
    if ($Array_vm[2] -eq "ADMSRV") {$Array_vm[2] = " ADMIN SERVER"}
    if ($Array_vm[2] -eq "MNGSRV") {$Array_vm[2] = " MANAGED SERVER"}
    if ($Array_vm[2] -eq "SRV121") {$Array_vm[2] = " SERVER 12.2"}
    if ($Array_vm[1] -eq "JBOSS" -and $Array_vm[2] -eq "DOMAIN" ) {$Array_vm[2] = " 7 APPLICATION SERVER"}
    if ($Array_vm[1] -eq "JBOSS" -and $Array_vm[2] -eq "STANDALONE" ) {$Array_vm[2] = " STANDALONE"}


    if ($Array_vm[2]) {$Array_vm[1] = $Array_vm[1] + $Array_vm[2]}
    
    if ($Array_vm[0] -eq "SLES12") {$Array_vm[1] = ""}

    
    
    


 # aggiorna i custom attribute
   $VirtM|Set-Annotation -customattribute "BASELINE" -Value "$baseline"

   $VirtM|Set-Annotation -customattribute "HARDENING" -Value "$hardening"
	
   $VirtM|Set-Annotation -customattribute "OS" -Value $Array_vm[0]
   if ($Array_vm.length -gt 1) {$VirtM|Set-Annotation -customattribute "MIDDLEWARE" -Value $Array_vm[1]} 
      else {$VirtM|Set-Annotation -customattribute "MIDDLEWARE" -Value ""}



#COnverte la VM in template

 $VirtM |Set-VM -Totemplate -confirm:$false



#Rinomina il nuovo template
Set-Template -Template $vm_new -Name $vm

#Sposta il template nella dir Templates
Move-Template -template $vm  -Destination $Folder







}