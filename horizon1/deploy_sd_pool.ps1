<# Prende cinque parametri d'ingresso tutti obbligatori

esegue il deploy di due desktop pool che hanno la stessa master ma sottoreti diverse
per SDA


nome  della master
nome del pool 
nome del connection server horizon
nome user per login sul server horizon
password per l'user
pre-requisti: 
 1) la master deve essere accesa
 2) avere le credenziali per l'accesso al vcenter nel credential store

esempio di utilizzo

.\deploy_sd_pool.ps1 -server  ASERl -d 8e -pg aste -c awer -user ajaj -password lalal

DA TESTARE

#>

param ([Parameter(Mandatory)]$server,[Parameter(Mandatory)]$desktoppool,[Parameter(Mandatory)]$cserver,[Parameter(Mandatory)]$user, [Parameter(Mandatory)]$password   )

$VM = Get-VM -name $server

#Verifica l'attuale ip della master e ricava il nomi del pool da utilizzare

$ipaddress = $VM.guest.ipaddress

$array = $VM.guest.ipaddress.split(".")
if ($array[3].length > 2) {$pool = $desktoppool + "SDSDA"
                           $pool_new = $desktoppool + "SISTSDA"
                           }
               else {$pool =$desktoppool + "SISTSDA" 
                     $pool_new = $desktoppool + "SDSDA"
                     }

#Verifica il nome del port group associato alla master e in base a questo ricava il nome del nuovo pg

$pg_attuale = (get-networkadapter -vm $VM).networkname
if ($pg_attuale -match "890") {$pg_new = $pg_attuale.replace('890','893')
                               
                               }
       else {$pg_new = $pg_attuale.replace('893','890') }

#verifica se la master è spenta e in caso contrario la spegne e poi crea il primo snapshot
if ($VM.PowerState -ne "PoweredOff" {
                                      $VM|Shutdown-VMGuest -confirm:$false
                                      while ($VM.extensiondata.guest.gueststate -ne "notRunning" ) {
                                                        write-host "$server is shutting down ..."
                                                        Start-sleep -Seconds 60
                                                        }

                                      Stop-vm -vm $VM -confirm:$false
                                     }
$NewSnapshot = New-Snapshot -vm $VM -name "aggiornamento con uso  $pg_attuale" -confirm:$false



#aggiorna il primo pool mantenendo il port group attuale
Connect-hvserver -server $cserver -user $user -password $password
Start-HVPool -SchedulePushImage -Pool $pool -LogoffSetting FORCE_LOGOFF -ParentVM $VM -SnapshotVM $NewSnapshot
Start-sleep -seconds 900

 #assegna il nuovo port group alla master
$ent = get-networkadapter -vm $VM
set-networkadapter -networkadapter $ent -portgroup $pg_new -confirm:$false


#avvia la master e verifica se ha preso un indirizzo ip
Start-VM -vm $VM
Start-sleep -Seconds 240
$ipaddress = $VM.guest.ipaddress
if (-not $ipaddress) {
                       write-host "Impossibile determinare l'indirizzo ip, problemi di assegnazione"
                       exit
                       }

#Spengo la master e creo un nuovo snapshot
$VM|Shutdown-VMGuest -confirm:$false
Start-sleep -Seconds 60
Stop-vm -vm $VM -confirm:$false
$NewSnapshot = New-Snapshot -vm $VM -name "change_of_pg in $pg_new" -confirm:$false
Start-sleep -seconds 240

#$NewSnapshot = GET-SNAPSHOT -VM $VM -NAME "change_of_pg PG_P_RM1_COMP_VDI02_890_E"

# Mi collego al connection server e lancio il deploy del pool

Connect-hvserver -server $cserver -user $user -password $password

Start-HVPool -SchedulePushImage -Pool $pool_new -LogoffSetting FORCE_LOGOFF -ParentVM $VM -SnapshotVM $NewSnapshot
    