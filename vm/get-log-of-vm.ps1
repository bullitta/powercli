<#
  prende DUE parametri d'ingresso:

  elenco macchine in cui effettuare lo scarico del file log
  
  nome del file
  
  E copia nella cartella c:\temp del pc locale il file
  
  Esempio di utilizzo

  .\get-log-of-vm.ps1 -s name2,name2 -f vmware.log

#>
param ([Parameter(Mandatory)]$servername, [Parameter(Mandatory)]$filename )

foreach ($VM in $servername) {

$vm = get-vm -name $VM

$view = get-view $vm
#RICAVO il path che contiene il file vmware.log
$vmxpath = $view.config.files.vmpathname

$ds = $vmxpath.split(' ')[0].trim('[').trim(']')

$datacenter = $vm|get-datacenter
$vmfolder = $($vmxpath.split('/')[0].replace(' ','\').replace('[','').replace(']',''))
set-location vmstore:
$logfile = "$($datacenter.name)\$($vmfolder)\$filename"
copy-datastoreitem -item $logfile -destination "c:\temp\$filename"
}
