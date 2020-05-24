#prende tre parametri d'ingresso tutti obbligatori
# esempio di lancio:
#.\update_template.ps1 -s RHEL74,WIN2016-MIDDL,WIN2012 -b 2020_T1 -h 2020_1


#aggiorna tutte le voci dei custom attribute in base ai nomi dei teMplate ed alle indicazioni che
#ci sono state fornite da alessio

param ([Parameter(Mandatory)]$server,[Parameter(Mandatory)]$baseline,[Parameter(Mandatory)]$hardening)


$servername = @($server.split(","))

Foreach ($vm in $servername) {
    $dir= $vm.SubString(0,3)
   
    $VirtM = Get-Template -name $vm
    # seguono una serie di pre-operazioni utili al popolamento dei custom attribute
    # in base al nome del template
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

}