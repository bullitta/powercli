<# Funziona solo su macchine windows e solo se nella macchina NON esistono più dischi con la
    stessa capacity
 prende tre parametri d'ingresso

lista vm 
nome drive hdisk in genere è del tipo: "c", oppure f....
size in gb dell'estensione

E calcola ed assegna la nuova dimesione  al disco
Presenta una routine che consente di ricavare il nome dell'unità disco in terminologia vmware a 
partire dal nome drive in termini windows

esempio di utilizzo:

.\estendi_hdisk_vm.ps1 -server arte1,arte2 -disk c -size 10

Per vedere a quale drive corrisponde il disco da estendere usa
$VM.Guest.Disks
che riporta capacity e nome win drive
#>

param ([Parameter(Mandatory)]$server, [Parameter(Mandatory)]$disk,[Parameter(Mandatory)]$size )


$servername = @($server.split(","))
$disk = $disk + ":" + "\"

Foreach ($vm in $servername) {

$VM = get-vm -name $vm

#Calcola l'unità disco da estendere in base al nome drive
#la procedura prevede i seg 2  passi:
#1 calcolo l'attuale capacity del disco da estendere, arrotondandolo a 0 decimali:
$capacity = $VM.Guest.Disks |WHERE-object -Property path -EQ $disk|select-object -property @{Name="roundCapacity";Expression={[math]::Round($_.CapacityGb)}}
$capacity = $capacity.roundCapacity
#2 determino il nome disco in termini vmware in base alla sua capacity arrotondata
$Hdisk = $VM|get-harddisk|where-object -Property CapacityGB -eq $capacity|select-object
 

# verifico se l'hdisk da estendere è stato individuato se non lo è stato interrompo lo script 
#con un messaggio:
if ( $Hdisk.Length -gt 1 ) {Write-Host "lo script non riesce ad individuare univocamente  il disco da estendere in base"
                  Write-Host "ai dati della capacity, occorre farsi inviare maggiori informazioni"
          Exit}
          
$size = $size + $Hdisk.CapacityGb
$size
$capacity
$Hdisk.name
#estendo il disco
#set-harddisk -Harddisk $Hdisk -CapacityGB $size -Confirm:$false



}
