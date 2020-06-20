<# clona una VM tramite copia dei file
richiede solo due parametri (obbligatori) d'ingresso:
1) l'elenco delle macchine da clonare tramite copia della cartella contenente il file vmx
2) il suffisso da dare al nome delle macchine clonate

Eempio di utilizzo

.\clona_tramite_copia_file.ps1 -server pas01d, pas04s -suffix 08082020_patch

Lo script crea la copia sullo stesso datastore in cui si trova la macchina originale

Prima della copia viene eseguito lo spegnimento della macchina originale e, dopo la copia file,
la registrazione del clone e il riavvio della macchina originale


#>


param ([Parameter(Mandatory)]$server,[Parameter(Mandatory)]$suffix)


Set-Location vmstore:





$servername = @($server.split(","))
$DatastoreName = @()



Foreach ($vm in $servername) {


#Ricava : Cluster, datacenter e Host  della vm da clonare

$cluster = Get-cluster -vm $vm
$Datacenter = get-datacenter -Cluster $cluster
$VMHost = Get-VMHost -vm $vm
$VMachine = Get-Vm -name $vm
$vm = $VMachine.name



#Ricava i datastore in cui si trovano i file della vm

$datastore = get-datastore -vm $vm|select -Property name
$datastore|foreach {
                    $name = @("$_".split('='))
                    $nome = $name[1].Substring(0,$name[1].Length-1)
                    $DatastoreName += $nome}





#spegne la macchina originale

Stop-VM -VM $vm -Confirm:$false



#Cerca il  datastore che contiene il file con i metadati della macchina .vmx

Foreach ($ds in $DatastoreName) {
                 
                   $Path = "vmstore:\$Datacenter\$ds\$vm"
                   $VmxFile = Get-item  $Path\*.vmx 
                   if ($VmxFile) {$ds_vmx = $ds
                                  
                                   }
                    }

                 

 #copia i file sullo stesso datastore e in una nuova cartella
                 
 $vm_new = $vm + "_" + $suffix  


  
    
 new-item -path vmstore:\$Datacenter\$ds_vmx -name $vm_new -ItemType "directory"


 $source = "vmstore:\$Datacenter\$ds_vmx\$vm"
 $dest = "vmstore:\$Datacenter\$ds_vmx\$vm_new"
 Copy-datastoreitem $source\*.vmx $dest
 Copy-datastoreitem $source\*.vmxf $dest
 Copy-datastoreitem $source\*.vmsd $dest
 Copy-datastoreitem $source\*.nvram $dest
 Copy-datastoreitem $source\$vm.vmdk $dest



#rinomina il file vmx e tutti i file vm*
mv $dest\$vm.vmx $dest\$vm_new.vmx
mv $dest\$vm.vmxf $dest\$vm_new.vmxf
mv $dest\$vm.vmsd $dest\$vm_new.vmsd
$filevmx = Get-Item $dest\*.vmx
                     
                 
 # registra la nuova macchina

New-VM -name $vm_new -VMHost $VMHost -VMfilePath $filevmx.DataStoreFullPath
 
# riavvia la macchina originale                  

Start-VM -VM $vm -Confirm:$false
 

}