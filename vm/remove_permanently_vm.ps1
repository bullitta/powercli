<# 
RIMUOVE SIA dall'inventory vsphere che dal datastore una serie di vm
esempio di lancio
.\remove_permanently_vm.ps1 -server server1,server2

#>


param ([Parameter(Mandatory)]$server)

$servername = @($server.split(","))

Foreach ($vm in $servername) {
                      
                     $VM = get-vm -name $vm
                     Remove-VM  -VM $VM -DeletePermanently -Confirm:$false
                     
                          }