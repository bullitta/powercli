<# lo script ricava l'elenco di tutte le vm contenute in un host esxi e il sist operativo
installato sulle vm e lo salva in  un file chiamato c:\temp\<nome host>-VM.csv

prende due parametri d'ingresso:
 nome host esxi
nome ambiente in cui si trova l'esxi
va lanciato in questo modo:

.\ricava-elenco-nomi-vm-sis-op-in-esxi.ps1 -e pepep -a certificazione


#>

param ($esxi,$csvName=("C:\temp\" + $esxi + "-VM.csv"), $ambiente)

# Ricava l'elenco vm,sis op, delle macchine contenute nell'esxi e lo salva nel file c:\temp\<nomw esxi>-VM.csv

#$vm_all = ($esxi + ";" + (GET-VM |WHERE-OBJECT {$_.VMHOST -like "$esxi"}|select-object  name,guestid|ft -hidetableheaders -autosize ) )> $csvName
(GET-VM |WHERE-OBJECT {$_.VMHOST -like "$esxi"}|select-object  name,guestid|ft -hidetableheaders -autosize) > $csvName


# Ricava il numero delle vm contenute nell'host:
$n = (GET-VM |WHERE-OBJECT {$_.VMHOST -like "$esxi"}).count


#Crea una matrice dal contenuto del file e rimuove il file:

$array_vm = get-content -Path $csvName
Remove-Item $csvName

# Sostituisce alla stringa vmware che definisce il guestid un nome più parlante

foreach ($vm in $array_vm) {

     #sostituisci gli spazi
         $vm = $vm -replace '\s+',''
      # aggiunge il  nome host e l'ambiente  a inizio riga 
         $vm = $esxi + ";" + $ambiente + ";" + $vm

         if ($vm -match "windows7_64Guest"){
                ($vm -replace 'windows7_64Guest',';Microsoft Windows 7 (64-bit)')| out-file -FilePath $csvName -Append}   
         
         if ($vm -match "windows9_64Guest"){
                ($vm -replace 'windows9_64Guest',';Microsoft Windows 10 (64-bit)')| out-file -FilePath $csvName -Append}   
         
          if ($vm -match "windows7Guest"){
                ($vm -replace 'windows7Guest',';Microsoft Windows 7 (32 bit)')| out-file -FilePath $csvName -Append}   
         

          
          if ($vm -match "other3xLinux64Guest"){
                ($vm -replace 'other3xLinux64Guest',';VMware Photon OS (64-bit)')| out-file -FilePath $csvName -Append}   
         
         
         if ($vm -match "otherGuest"){
                ($vm -replace 'otherGuest',';Other Linux')| out-file -FilePath $csvName -Append}   
         
         
         if ($vm -match "otherLinux64Guest"){
                ($vm -replace 'otherLinux64Guest',';Other Linux (64-bit)')| out-file -FilePath $csvName -Append}   
         
         if ($vm -match "sles12_64Guest"){
                ($vm -replace 'sles12_64Guest',';SUSE Linux Enterprise 12 (64-bit)')| out-file -FilePath $csvName -Append}   
         
          if ($vm -match "sles11_64Guest"){
                ($vm -replace 'sles11_64Guest',';SUSE Linux Enterprise 11 (64-bit)')| out-file -FilePath $csvName -Append}   
         
         
         if ($vm -match "centos6Guest"){
                ($vm -replace 'centos6Guest',';CentOS 6 Linux (32-bit)')| out-file -FilePath $csvName -Append}   
         
         
         if ($vm -match "centos7_64Guest"){
                ($vm -replace 'centos7_64Guest',';CentOS 7 Linux (32-bit)')| out-file -FilePath $csvName -Append}   
         
         
         if ($vm -match "centos64Guest"){
                ($vm -replace 'centos64Guest',';CentOS Linux (64-bit)')| out-file -FilePath $csvName -Append}   
         
          if ($vm -match "ubuntuGuest"){
                ($vm -replace 'ubuntuGuest',';Ubuntu Linux (32-bit)')| out-file -FilePath $csvName -Append}   
         
          
          if ($vm -match "ubuntu64Guest"){
                ($vm -replace 'ubuntu64Guest',';Ubuntu Linux (64-bit)')| out-file -FilePath $csvName -Append}   
         
          if ($vm -match "debian5_64Guest"){
                ($vm -replace 'debian5_64Guest',';Debian 5 Linux (64-bit)')| out-file -FilePath $csvName -Append}   
         

         if ($vm -match "rhel5_64Guest"){
                ($vm -replace 'rhel5_64Guest',';RED HAT ENTERPRISE LINUX 5')| out-file -FilePath $csvName -Append}   
         if ($vm -match "rhel6_64Guest"){
                ($vm -replace 'rhel6_64Guest',';RED HAT ENTERPRISE LINUX 6 (64-BIT)')| out-file -FilePath $csvName -Append} 
         if ($vm -match "rhel7_64Guest"){
                ($vm -replace 'rhel7_64Guest',';RED HAT ENTERPRISE LINUX 7 (64-BIT)')| out-file -FilePath $csvName -Append}
         
         if ($vm -match "windows7Server64Guest"){
                ($vm -replace 'windows7Server64Guest',';Microsoft Windows Server 2008 R2 (64-bit)')| out-file -FilePath $csvName -Append}
         
         if ($vm -match "windows8Server64Guest"){
            ( $vm -replace 'windows8Server64Guest',';Microsoft Windows Server 2012 (64-bit)')| out-file -FilePath $csvName -Append}
         
         if ($vm -match "winLonghorn64Guest"){
            ($vm -replace 'winLonghorn64Guest',';Microsoft Windows Server 2008 (64-bit)')| out-file -FilePath $csvName -Append}
         
         if ($vm -match "windows9Server64Guest"){
            ($vm -replace 'windows9Server64Guest',';Microsoft Windows Server 2016 (64-bit)')| out-file -FilePath $csvName -Append}
         
         
         }

# Verifica se tutte le vm contenute nell'esxi sono state riportate sul file e, in caso contrario, avvisa che vi sono delle macchine con 
#sis op non identificato
$diff =  $n - (get-content c:\temp\$esxi-VM.csv|measure-object -line).lines

if ($diff > 0) {write-host ("ci sono ancora $diff macchine non censite sull'host")}


