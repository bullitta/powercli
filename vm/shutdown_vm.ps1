<# shutdown vm
CHIUDE una serie di vm
esempio di lancio
.\shutdown_vm.ps1 -server server1,server2

#>


param ([Parameter(Mandatory)]$server)

$servername = @($server.split(","))

Foreach ($vm in $servername) {
                      
                     $VM = get-vm -name $vm
                     shutdown-VMguest -VM $VM -Confirm:$false
                     ##...dò 60 secondi per uno stop pulito
                    # start-sleep -s 60
                    # if ($VM.extensiondata.guest.gueststate -eq "notRunning") {$VM|stop-vm -Confirm:$false|out-null}
                          }