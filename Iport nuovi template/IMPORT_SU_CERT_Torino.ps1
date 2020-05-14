<# 
questo script importa le vm nell'ambiente di certificazione di Torino
prima di lanciarlo occorre collegarsi al server con il comando:
Connect-VIServer -server ctopcmvcpyl01v.rete.poste -u .... -p .....
Prende tre parametri d'ingresso tutti obbligatori e va lanciato nel seguente modo:

.\Import_pvf_su_cert.ps1 -s WIN2012,WIN2012-ORACLEDB121,RHEL76 -b 2020_T1 -h 2020_1

#>

param ([Parameter(Mandatory)]$server,[Parameter(Mandatory)]$baseline,[Parameter(Mandatory)]$hardening)

# mi collego alla share dei template

New-PSDrive -Name Z -PSProvider FileSystem -Root \\dcpt000s020\CC_VMWARE\PrivateCloud\Templates 



$servername = @($server.split(","))

#Imposto alcune variabili che mi serviranno per l'import, uno anche per lo spostamento della macchina
#nel folder Templates ($Folder)
$DATASTORE = "C_TO_COMP_NETAPP"
$VMHOST = Get-VMHost -name *comp*esx01*
$Folder = Get-Folder -Name Templates
$PORTGROUP = Get-VDPortgroup -name vxw-dvs-70-virtualwire-92-sid-5019-TO-M2-LS-CERT-b5607fed-ef2c-460b-addb-637469b


z:



Foreach ($vm in $servername) {

$vm_new = $vm + "_" + "$baseline"
$dir= $vm.SubString(0,3)
if ($dir -eq "RHE") {$dir = "RHEL"}
if ($dir -eq "SLE") {$dir = "SUSE"}

$ovffile = $vm_new + ".ovf"
$OvfConfiguration = Get-OvfConfiguration -Ovf "$dir\CURRENT\$vm\$ovffile"


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
    if ($Array_vm[1] -eq "APACHE2437") {$Array_vm[1] = "APACHE HTTPD SERVER 2.4"}
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


#Sposta la vm nella dir Templates
$VirtM | Move-VM -Destination $Folder

#COnverte la VM in template

 $VirtM |Set-VM -Totemplate -confirm:$false

#Cancella il vecchio template

Remove-Template -Template $vm -DeletePermanently -Confirm:$false

#Rinomina il nuovo template
Set-Template -Template $vm_new -Name $vm







}