<#
prende come ingresso un solo parametro: la lista dei cloni da verificare, ed esegue
le seguenti operazioni:
disattiva le interfaccie di rete del clone
avvia il clone
attende 
spegne il clone
riassegna le interfacce di rete

esempio di utilizzo

.\prova_stato_clone_vm.ps1 -server afaft,ayatr


#>

param ([Parameter(Mandatory)]$server)


$servername = @($server.split(","))


Foreach ($vm in $servername) {

     $VM = GET-VM -name $vm
     $nw_adapter = $VM|get-networkadapter
     foreach ($nw in $nw_adapter) {set-networkadapter -NetworkAdapter $nw -StartConnected:$false -Confirm:$false}
     

     $VM|Start-vm -Confirm:$false|out-null
#Effetua lo start di prova     
     $VM = get-vm -name $vm
# a seconda della vm 60 sec potrebbero non essere suff per trovarla in stato running
     start-sleep -s 60
     

     if ($VM.extensiondata.guest.gueststate -eq "running") {
              #Il comando Stop-VMGuest funziona solo se sulla macchina sono presenti i vmware tool
              #Stop-VMGuest -VM $VM -Confirm:$false
              $VM|Stop-vm -Confirm:$false|out-null
              write-host "Verifica clone $server terminata con successo"
            }
        else {write-host "Problemi con la ripartenza del clone $server verificare le operazioni di copia svolte"
              #Exit()
             }
     
     


}
