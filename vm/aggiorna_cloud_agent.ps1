<#
  Aggiorna cloud agent su template windows
  lo script aggiunge lo script non iterattivo:  prepare_vra_template1.ps1 alla cartella 
   C:\PREPARE_VRA\prepare_vra_template_windows\prepare_vra_template_windows
   e lo esegue
   Poi
  PRENDE 5 parametri d'ingresso:
    1) elenco dei server su cui deve essere effettuato l'aggiornamento
    2) password dell'user administrator delle macchine
    3) ip d assegnare alla vm
    4)dns da assegnre alla vm
    5) gateway da assegnare alla vm

  Esempio di utilizzo:
  .\aggiorna_cloud_agent.ps1 -server qwte,atre -pwd password -ip 10.11.1.1 -dns 10.2.3.1 -gateway 1.1.1.1

ATTENZIONE lo script prepare_vra_template1.ps1 per funzionare ha bisogno che la vm sia collegata alla rete
per questo motivo i parametri ip, dns e gateway vanno visti di volta in volta, in generale si ricavano andando a 
vederli sul vRealize  Automation: tab infrastruttura e poi prenotazioni ---> profili di rete


#>
param ([Parameter(Mandatory)]$server,[Parameter(Mandatory)]$pwd,[Parameter(Mandatory)]$ip,[Parameter(Mandatory)]$dns,[Parameter(Mandatory)]$gw)

$servername = @($server.split(","))

$Folder = Get-Folder -Name Templates







Foreach ($vm in $servername) {



$vm_template = Get-Template -name $vm

#Determino l'host in cui si trova il template
$VMHOST = (Get-View -ViewType VirtualMachine -Filter @{'Name'="$vm$"} |Select Name,@{N='VMHost';E={Get-View -Id $_.Runtime.Host -Property Name | Select -ExpandProperty Name}}).VMhost

$cluster = Get-cluster -vmHOST $VMHOST

if (-not $cluster) {
                   write-host "Problema nell'identificazione del cluster del vecchio template"
                   Write-Host "Verificare la presenza del vecchio template prima di proseguire"
                   exit
                   }



#Ricavo il datastore da utilizzare per creare la vm 
# seleziona i datastore con multipath visibili al cluster che non contengono BCK e REPL e altri #suffissi nel nome



$Datastore = $cluster|get-datastore | where {$_.ExtensionData.Summary.MultipleHostAccess -eq 'true'}|sort-object -Property freespacegb -descending|select name

$valid_datastore = @()

$Datastore|foreach {if ($_ -NOTmatch "BCK" -and $_ -NOTMatch "REPL" -and $_ -NOTMatch "SRM" -and $_ -notmatch "library" -and $_ -notmatch "NAS" -and $_ -notmatch "VOIP" -and $_ -notmatch "GENESYS" -and $_ -notmatch "NFS" -and $_ -notmatch "OPSH") {
                                                                     $name = @("$_".split('='))
                                                                     $nome = $name[1].Substring(0,$name[1].Length-1)
                                                                     $valid_datastore += "$nome"
                                                                     }
                       }

#Questa parte serve a bypassare il problema della presenza di nomi  duplicati dei datastore (stesso nome ma id diverso)
$dstoreid = @($Cluster|get-datastore -name $valid_datastore[0])
$DATASTORE = get-datastore -id $dstoreid[0].id





#Crea una nuova vm su cui dovranno essere eseguiti le operazioni di aggiornamento dell'agent

$vm_new = $vm + "_agg_cloud_agent"

New-VM -name $vm_new -Template $vm_template -resourcePool $cluster -datastore $DATASTORE



$VMachine = GET-VM -name $vm_new

$USER = $VMachine.extensiondata.guest.hostname + "\"  + "ADMINISTRATOR"

# nell'ipotesi che la vm abbia una sola scheda di rete, aggiunge il port group che termina in PROD-02
# ad eccezione dei sistemi su SDDC Torino dove invece per un refuso bisogna cercare quello che termina 
# con 02-PROD
# vxw-dvs-153-virtualwire-7-sid-5006-TO-M2-LS-Prod-02-PROD

  
$PGROUP = GET-VDPORTGROUP|WHERE -PROPERTY name -MATCH "PROD-02$"|WHERE -PROPERTY VDSwitch -MATCH "DVS_P_RM1_WIN_PCM01_NEW"




$netadapter = $VMachine|Get-NetworkAdapter
Set-NetworkAdapter -Networkadapter $netadapter -PortGroup $PGROUP -Confirm:$false




#starta la vm Assegna: ip - gateway, dns

Start-VM -vm $VMachine
# a SECONDA della versione di windows imposta i comandi per l assegnazione dell ip e del dns

if ( $vm -match "2012") {
               $assign_ip = "netsh interface ipv4 set address name=Ethernet0 static $ip 255.255.240.0 $gw"
               $assign_dns = "netsh interface ipv4 set dns name=Ethernet0 static $dns"
               }
if ( $vm -match "2016") {
               $adapter = '"Ethernet0 2"'
               $assign_ip = "netsh interface ipv4 set address $adapter  static $ip 255.255.240.0 $gw"
               $assign_dns = "netsh interface ipv4 set dnsserver $adapter static $dns primary"
               }

 #PRIMA di lanciare i comandi sulla vm aspetta 60 sec, 
 # a seconda della vm 60 sec potrebbero non essere suff per trovarla in stato running
     start-sleep -s 60              

Invoke-vmscript -vm $VMachine -scriptText $assign_ip -scripttype bat -GuestUser $USER -GuestPassword $pwd 
Invoke-vmscript -vm $VMachine -scriptText $assign_dns -scripttype bat -GuestUser $USER -GuestPassword $pwd

# mi collego alla share che contiene lo script d'installazione dell'agent e il .bat

#ACCESSO AI FILE 
New-PSDrive -Name Y -PSProvider FileSystem -Root "\\dcpt000s020\CC_VMWARE\z_giovanni\software components"

if (-not (get-psdrive Y)) {write-host "impossibile collegarsi alla dir degli script d'installazione"
                          exit}



#Copia lo script non interattivo prepare_vra_template1.ps1 nella vm

$destination = "C:\PREPARE_VRA\prepare_vra_template_windows\prepare_vra_template_windows"
Get-item "y:\prepare_vra_template1.ps1"| copy-vmGuestFile -LocalToGuest -VM $VMachine  -Destination $destination -guestuser $USER -guestpassword $pwd -confirm:$false -force


#Esegue lo script prepare_vra_template.ps1 nella vm
Invoke-vmscript -vm $VMachine -scriptText "$destination\prepare_vra_template1.ps1" -Guestuser $USER -guestpassword $pwd


#Copia il file bat  nella vm

$destination1 = "C:\opt\vmware-appdirector\agent-bootstrap"
Get-item "y:\vcac-appd-gc.bat"| copy-vmGuestFile -LocalToGuest -VM $VMachine  -Destination $destination1 -Guestuser $USER -guestpassword $pwd -confirm:$false -force

# Pulisce gli event log
$logtype = "application,security,system,hardwareevents"
$clean_evt_log = "Clear-EventLog -LogName $logtype"
 Invoke-vmscript -vm $VMachine -scriptText $clean_evt_log -Guestuser $USER -guestpassword $pwd

# fa una chiusura pulita del guest host
Stop-VMGuest -VM $VMachine -Confirm:$false



#Chiude la VM e genera il nuovo template
$VMachine|Stop-vm -Confirm:$false|out-null
$VMachine |Set-VM -Totemplate -confirm:$false
#Cancella il vecchio template solo se Ã¨ gia presente il nuovo

if (get-template -name $vm_new) {Remove-Template -Template $vm -DeletePermanently -Confirm:$false}

#Rinomina il nuovo template
Set-Template -Template $vm_new -Name $vm

#Sposta il template nella dir Templates
Move-Template -template $vm  -Destination $Folder

#valorizza i custom attribute del template in base al nome 
# correggere i valori di baseline e hardening in base allo stato del software sul template
cd "..\aggiornamento template"
.\update_template.ps1 -s $vm -b 2020_T2 -h 2020_1

}

remove-psdrive -literalname Y
