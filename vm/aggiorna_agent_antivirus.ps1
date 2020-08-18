<#
  Aggiorna agent su template windows
  lo script inserisce i nuovi pacchetti dell'agent antivirus nella cartella
   C:\Software\Antivirus\windows
   i tre paccchetti:
  FramePkg_56_SVIL.exe,FramePkg_56_CERT.exe,FramePkg_56_PROD.exe
  PRENDE due parametri d'ingresso:
    1) elenco dei server su cui deve essere effettuato l'aggiornamento
    2) password dell'user administrator delle macchine

  Esempio di utilizzo:
  .\aggiorna_agent_antivirus.ps1 -server qwte,atre -pwd password

ATTENZIONE va lanciato dalla stessa directory in cui è presente lo script McAffe_endpoint_script.ps1

#>



param ([Parameter(Mandatory)]$server,[Parameter(Mandatory)]$pwd)


# mi collego alla share che contiene i nuovi agent


#ACCESSO AI FILE FramePkg*
New-PSDrive -Name Y -PSProvider FileSystem -Root \\dcpt000s020\CC_VMWARE\PrivateCloud\Agent\Antivirus\Windows\07_2020\1_WIN_Agent_562

if (-not (get-psdrive Y)) {write-host "impossibile collegarsi alla dir degli agent antivirus"
                          exit}

#Accesso al file endpoint
New-PSDrive -Name Q -PSProvider FileSystem -Root \\dcpt000s020\CC_VMWARE\PrivateCloud\Agent\Antivirus\Windows\07_2020\2_WIN_ENS_10.7
if (-not (get-psdrive Q)) {write-host "impossibile collegarsi alla dir degli endpoint dell'agent antivirus"
                          exit}

$destination = "C:\Software\Antivirus\windows"

 


$servername = @($server.split(","))


Foreach ($vm in $servername) {

$vm_new = $vm + "_2020_T2"

$VMachine = GET-VM -name $vm_new

$USER = $VMachine.extensiondata.guest.hostname + "\"  + "ADMINISTRATOR"


#Copia i file FramePkg nella vm
Get-item "y:\FramePkg*"| copy-vmGuestFile -LocalToGuest -VM $VMachine  -Destination $destination -guestuser $USER -guestpassword $pwd -confirm:$false -force

#Copia il file zip con la  dir MCaffe_enpoint nella vm
Get-item "Q:\McAfee_Endpoint_Security*"| copy-vmGuestFile -LocalToGuest -VM $VMachine  -Destination $destination -Guestuser $USER -guestpassword $pwd -confirm:$false -force

#Copia lo script che esegue la predisposizione della dir endpoint

Get-item "McAffe_endpoint_script.ps1"| copy-vmGuestFile -LocalToGuest -VM $VMachine  -Destination $destination -Guestuser $USER -guestpassword $pwd -confirm:$false -force


#Esegue lo script

Invoke-vmscript -vm $VMachine -scriptText "$destination\McAffe_endpoint_script.ps1" -Guestuser $USER -guestpassword $pwd

if ($vm -match "WIN2012")  {
                          # Invoke-vmscript -vm $VMachine -ScriptType Bat -scriptText "unzip McAfee_Endpoint_Security_10.7.0.667.6_standalone_client_install.zip " -Guestuser $administrator -guestpassword $pwd
                           }                                                     

#Rimuove lo script dalla vm

#Invoke-vmscript -vm $VMachine -scriptText "remove-item -path $destination\McAffe_endpoint_script.ps1" -Guestuser $USER -guestpassword $pwd






}

remove-psdrive -literalname Y,Q
    
