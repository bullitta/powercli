<# Lo script crea una nuova vm e monta un file iso 
   Prende cinque  parametri d'ingresso:
   Il nome della vm
   Il nome del cluster in cui si vuole creare la vm
   Il nome del file iso
   la ram da assegnare in Gb
   le cpu da assegnare
   Esempio di lancio:
   .\create_vm_from_scratch.ps1 -server vm1 -cluster Clu -iso yubutu.iso -ram 4 -cpu 2
   IMPORTANTE IL FILE ISO DEVE TROVARSI SULLA STESSA DIR DELLO SCRIPT
#>

param ([Parameter(Mandatory)]$server, [Parameter(Mandatory)]$cluster, [Parameter(Mandatory)]$iso,[Parameter(Mandatory)]$ram, [Parameter(Mandatory)]$cpu  )

$Cluster = get-cluster -name $cluster
$split_iso =  @($iso.split("-"))
$os_type = $split_iso[0] + "64" + "Guest"






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

##..Creo la vm e cambio il tipo di Guest id in base al nome della iso
New-VM -Name $server -ResourcePool $Cluster -Datastore $dstore -MemoryGb $ram -NumCpu $cpu
Set-VM  $server -GuestId $os_type -Confirm:$false

##.. In caso il sys op è ubuntu corregge un problema relativo al tipo bus scsi

if ( $split_iso[0] -eq "ubuntu") {Get-scsicontroller -vm $server|Set-ScsiController -Type VirtualLsiLogic -Confirm:$false}

##.. ricostruisco il path in cui si trovano i file della nuova vm
$dcenter = get-datacenter -vm $server
$destination_path = "vmstore:\$dcenter\$dstore\$server\"



##..Copia il file iso sul datastore dove si trova la nuova vm

Copy-datastoreitem  -item $iso -Destination $destination_path

##..collego il file iso alla vm
$cd = New-CDdrive -VM $server -ISOPath "[$dstore] $server\$iso"  -Startconnected
Set-CDdrive -CD $cd  -Confirm:$false





