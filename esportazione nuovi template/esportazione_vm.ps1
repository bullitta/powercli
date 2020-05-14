<#
  esporto lE vm

 ESEMPIO di lancio: 
.\esportazione_vm.ps1 -s RHEL76,WIN2012,RHEL75 -b 2020_T1 -h 2020_1 -O 2019_T4

 esegue in ordine le seg operazioni: 
   - aggiorna i custom attribute in base ai nomi delle macchine e ai parametri baseline (b) e hardening (h)
   -  sposta il vecchio export da current a old nella share
   -   spegne le vm   
   -   modifica le proprietà della rete delle vm 
   - le esporta nella current dir, 
   - ripristina le vecchie proprietà di rete
   - rinomina la dir di esportazione e quella che conserva il vecchio template
   -  converte le vm in template
   -  rimuove il vecchio template
   - rinomina il nuovo template
 
#>

param ([Parameter(Mandatory)]$server,[Parameter(Mandatory)]$baseline,[Parameter(Mandatory)]$hardening, [Parameter(Mandatory)]$oldbaseline)

# mi collego alla share dei template



New-PSDrive -Name Z -PSProvider FileSystem -Root \\dcpt000s020\CC_VMWARE\PrivateCloud\Templates 






$servername = @($server.split(","))


Foreach ($vm in $servername) {
    
    $dir= $vm.SubString(0,3)
    $vm_new = $vm + "_" + $baseline
    $vm_old = $vm + "_" + $oldbaseline
   
    $VirtM = Get-VM -name $vm_new
    # seguono una serie di pre-operazioni utili al popolamento dei custom attribute
    # in base al nome della vm
    if ($dir -eq "RHE") {$dir = "RHEL"}
    if ($dir -eq "SLE") {$dir = "SUSE"}
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


#Sposta le dir da Current a Old


z:



Move-item $dir\CURRENT\$vm  old\$dir\



#chiude la vm 

Stop-VMGuest  -VM  $VirtM -Confirm:$false
Stop-VM  -VM $VirtM -Confirm:$false




#modifica le proprietà della rete

$ADAPTER = Get-VM -name "$vm_new"|Get-NetworkAdapter
$PORTGROUP = $ADAPTER.NetworkName
$PORTGROUP_new = Get-VDPortgroup -name "DPortGroup"



Get-VM -name "$vm_new"|Get-NetworkAdapter|Set-NetworkAdapter -NetworkName "$PORTGROUP_new" -StartConnected:$true -Confirm:$false


# esporta la vm 




get-vm -name $vm_new |Export-vapp -Destination $dir\CURRENT\

#rinomina la dir di esportazione

Rename-Item "$dir\CURRENT\$vm_new" $vm

# rinomina la dir old

Rename-Item "OLD\$dir\$vm" $vm_old



#Ripristina le precedenti proprietà della rete

Get-VM -name "$vm_new"|Get-NetworkAdapter|Set-NetworkAdapter -NetworkName "$PORTGROUP" -StartConnected:$true -Confirm:$false


#COnverte la VM in template

Get-VM -name $vm_new |Set-VM -Totemplate -confirm:$false

#Cancella il vecchio template

Remove-Template -Template $vm -DeletePermanently -Confirm:$false

#Rinomina il nuovo template
Set-Template -Template $vm_new -Name $vm



}