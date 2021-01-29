<# Lo script  monta un file iso su una vm
   Prende due  parametri d'ingresso:
   Il nome della vm
   Il nome del file iso
   Agisce effettuando la copia del file iso sul datastore della vm e 
   Esempio di lancio:
   .\mount_iso_file.ps1 -server vm1,vm2  -iso yubutu.iso 
   
   IMPORTANTE IL FILE ISO DEVE TROVARSI SULLA STESSA DIR DELLO SCRIPT INOLTRE E' NECESSARIO CHE LA VM
   SIA SPENTA, qualora non fosse possibile spegnerla le ultime due operazioni vanno fatte da console grafica
   EVITARE DI USARE LA VRC (vmware remote console) perchè altrimenti bisogna lasciare la sessione vrc attiva 
   per garantire la connessione all'iso
#>

param ([Parameter(Mandatory)]$server, [Parameter(Mandatory)]$iso)

$servername = @($server.split(","))

Foreach ($vm in $servername) {
    $Cluster = get-cluster -vm $vm
    $dcenter = get-datacenter -vm $vm
                      

##.. seleziono il datastore in cui inserire i file della nuova vm ed il file iso

$dstore = get-datastore -vm $vm

##.. ricostruico il path in cui andare a scaricare il file iso


$destination_path = "vmstore:\$dcenter\$dstore\$server\"

if (get-childitem -Path $destination_path) {}
    else {$server1 = $server.ToLower()
          $destination_path = "vmstore:\$dcenter\$dstore\$server1\"
          }


##..Copia il file iso sul datastore dove si trova la nuova vm

Copy-datastoreitem  -item $iso -Destination $destination_path

##..collego il file iso alla vm
$cd = New-CDdrive -VM $vm -ISOPath "[$dstore] $server\$iso"  -Startconnected
Set-CDdrive -CD $cd  -Confirm:$false

                              }