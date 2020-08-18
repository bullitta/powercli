<# Rimuove tutti i  cd da una serie di macchine


  esempio di utilizzo
  .\remove_cd_from_vm.ps1 -server vm1,vm2
ATTENZIONE FUNZIONA SOLO SE LE VM sono spente
#>


param ([Parameter(Mandatory)]$server)

$servername = @($server.split(","))

Foreach ($vm in $servername) {
    
  $cd = get-vm -name $vm|get-cddrive
  
  remove-cddrive -cd $cd -Confirm:$false


 }
