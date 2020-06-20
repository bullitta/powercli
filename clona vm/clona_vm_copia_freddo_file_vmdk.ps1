
write-host "NON FUNZIONA"
Exit()

<#
Prede tre parametri d'ingresso entrambi obbligatori

Lista delle vm su cui operare
Lista dei vm disk da copiare

Crea una clone della vm copiando solo i vmdisk indicati

esempio di utilizzo:
.\clona_vm_copia_freddo_file_vmdk.ps1 -server shshs -disk "Hard disk 1","Hard disk 2"
#>

param ([Parameter(Mandatory)]$server,[Parameter(Mandatory)]$disk, [Parameter(Mandatory)]$suffix)


$servername = @($server.split(","))
$hdisk = @($disk.split(","))

Foreach ($vm in $servername) {






$VMachine = Get-Vm -name $vm
$vm = $VMachine.name

#Ricava : Cluster, datacenter, datastore e Host  della vm da clonare

$cluster = Get-cluster -vm $vm
$Datacenter = get-datacenter -Cluster $cluster
$Datastorename = get-vm -name $vm|get-datastore
$VMHost = Get-VMHost -vm $vm


<#Ricavo il datastore da utilizzare per salvare la copia dei cloni
  seleziona i datastore con multipath visibili al cluster che non contengono:
  BCK, REPL, SRM, library, nas nel nome 
  e lo salvo nella variabile $dstore
#>



$Datastore = $Cluster|get-datastore | where {$_.ExtensionData.Summary.MultipleHostAccess -eq 'true'}|sort-object -Property freespacegb -descending|select name

$valid_datastore = @()

$Datastore|foreach {if ($_ -NOTmatch "BCK" -and $_ -NOTMatch "REPL" -and $_ -NOTMatch "SRM" -and $_ -notmatch "library" -and $_ -notmatch "nas") {
                                                                     $name = @("$_".split('='))
                                                                     $nome = $name[1].Substring(0,$name[1].Length-1)
                                                                     $valid_datastore += "$nome"
                                                                     }
                       }

#Questa parte serve a bypassare il problema della presenza di nomi  duplicati dei datastore (stesso nome ma id diverso)
$dstoreid = @($Cluster|get-datastore -name $valid_datastore[0])
$dstore = get-datastore -id $dstoreid[0].id

#$dstore






#spegne la macchina originale

#Stop-VM -VM $vm -Confirm:$false



#Cerca il  datastore che contiene il file con i metadati della macchina .vmx

Foreach ($ds in $DatastoreName) {
                 
                   $Path = "vmstore:\$Datacenter\$ds\$vm"
                   $VmxFile = Get-item  $Path\*.vmx 
                   if ($VmxFile) {$ds_vmx = $ds
                                  
                                   }
                    }




#copia i file della vm   in una nuova cartella
                 
 $vm_new = $vm + "_" + $suffix  


  
    
 new-item -path vmstore:\$Datacenter\$dstore -name $vm_new -ItemType "directory"

#Copia i file della vm


 $source = "vmstore:\$Datacenter\$ds_vmx\$vm"
 $dest = "vmstore:\$Datacenter\$dstore\$vm_new"


 Copy-datastoreitem $source\*.vmx $dest
 Copy-datastoreitem $source\*.vmxf $dest
 Copy-datastoreitem $source\*.vmsd $dest
 Copy-datastoreitem $source\*.nvram $dest


#Copia i virtual disk

foreach ($hd in $hdisk) { 
                        $disco = get-vm -name $vm|get-harddisk |where-object {$_.name -eq $hd}
                        $diskfile = $disco.filename
                        $diskfile1 = @($diskfile.split(" "))
                        $diskfile2 = $diskfile1[1] -replace "\/","\"
                        $diskpath = "vmstore:\$Datacenter\$ds_vmx\$diskfile2" 
                        Copy-datastoreitem $diskpath $dest 
                     }


<#
#rinomina il file vmx e tutti i file vm*
mv $dest\$vm.vmx $dest\$vm_new.vmx
mv $dest\$vm.vmxf $dest\$vm_new.vmxf
mv $dest\$vm.vmsd $dest\$vm_new.vmsd
mv $dest\$vm.vmdk $dest\$vm_new.vmdk

$filevmx = Get-Item $dest\*.vmx
                     
                 
 # registra la nuova macchina

#New-VM -name $vm_new -VMHost $VMHost -VMfilePath $filevmx.DataStoreFullPath
 

#>

}