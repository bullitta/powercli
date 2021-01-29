<# Lo script crea una nuova vm e monta un file iso 
   Prende sette  parametri d'ingresso:
   Il nome della vm
   Il nome del cluster in cui si vuole creare la vm
   Il nome del file iso
   la ram da assegnare in Gb
   le cpu da assegnare
   il nome del portgroup
   il tipo di sis op (per per VDI ho queste tre opzioni: win7, win10 e win2012
   
   Esempio di lancio:
   .\create_vm_from_scratch.ps1 -server vm1 -cluster Clu -iso tu.iso -ram 4 -cpu 2 -portg AKTY -op win10
   
   Una volta creata la vm vengono eseguite le seg modifiche
    
   modifica dello scsi buffer in tipo LSI logic sas (vedi prb he BusLogic SCSI adapter
    is not supported for 64-bit guests. See the documentation for the appropriate type of SCSI adapter to use with 64-bit guests.
An error was received from the ESX host while powering on )
  
   
   modifica dell' adapter  di rete in tipo VMXNET 3
#>

param ([Parameter(Mandatory)]$server, [Parameter(Mandatory)]$cluster, [Parameter(Mandatory)]$iso,[Parameter(Mandatory)]$ram, [Parameter(Mandatory)]$cpu, [Parameter(Mandatory)]$portg )

$Cluster = get-cluster -name $cluster

# Ricavo il portgroup
$pg = get-vdportgroup -name $portg
# ricavo il virtualmachineGuestOsIdentifier
if ($op -match win10 {$op = "windows9_64Guest"}
 else if ($op -match win2012) {$op = "windows8Server64Guest"}
   else if ($op -match win7) {$op = "windows7_64Guest"}







##.. seleziono il datastore in cui inserire i file della nuova vm ed il file iso
##.. criterio di selzione: il dstore di dimensione maggiore a meno di alcuni riservati

$Datastore = $Cluster|get-datastore | where {$_.ExtensionData.Summary.MultipleHostAccess -eq 'true'}|sort-object -Property freespacegb -descending|select name

$valid_datastore = @()

$Datastore|foreach {if ($_ -NOTmatch "BCK" -and $_ -NOTMatch "REPL" -and $_ -NOTMatch "SRM" -and $_ -notmatch "library" -and $_ -notmatch "NAS") {
                                                                     $name = @("$_".split('='))
                                                                     $nome = $name[1].Substring(0,$name[1].Length-1)
                                                                     $valid_datastore += "$nome"
                                                                     }
                       }

#Questa parte serve a bypassare il problema della presenza di nomi  duplicati dei datastore (stesso nome ma id diverso)
$dstoreid = @($Cluster|get-datastore -name $valid_datastore[0])
$dstore = get-datastore -id $dstoreid[0].id



##..Creo la vm 



New-VM -Name $server -ResourcePool $Cluster -Datastore $dstore -MemoryGb $ram -NumCpu $cpu -diskGb 30 -portgroup $pg -GuestId $op




##.. ricostruisco il path in cui si trovano i file della nuova vm
$dcenter = get-datacenter -vm $server
$destination_path = "vmstore:\$dcenter\$dstore\$server\"



##..Copia il file iso sul datastore dove si trova la nuova vm

Copy-datastoreitem  -item $iso -Destination $destination_path

##..collego il file iso alla vm
$cd = New-CDdrive -VM $server -ISOPath "[$dstore] $server\$iso"  -Startconnected
Set-CDdrive -CD $cd  -Confirm:$false

# iMPOSTO il network adapter della nuova vm
$adapter = get-networkadapter -vm $server
Set-NetworkAdapter -networkadapter $adapter -type VMXNET3 -confirm:false

# Imposta il tipo di SCSI controller
$scsiadapter = get-scsicontroller -vm $server
set-scsicontroller -scsicontroller $scsiadapter -type virtuallsilogicsas



