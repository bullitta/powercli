#prende due parametri d'ingresso tutti obbligatori
# esempio di lancio:
#.\create_vm_for_Vuln_Ass.ps1 -s RHEL74,WIN2016-MIDDL,WIN2012 -b 2020_T1
# E Crea nuove vm a partire da template presenti nel vcenter
# sempre per proseguire nell'esempio verranno create le vm:
# RHEL74_2020_T1,WIN2016-MIDDL_2020_T1,WIN2012_2020_T1


param ([Parameter(Mandatory)]$server,[Parameter(Mandatory)]$baseline)

$Cluster = Get-Cluster -Name S_TO_COMP

$servername = @($server.split(","))


Foreach ($vm in $servername) {

$vm_new = $vm + "_" + "$baseline"




#creo la VM dal template

New-VM -Name $vm_new -Template $vm -ResourcePool $Cluster 



# sposto la VM nella dir Templates

Get-VM -name $vm_new| Move-VM -Destination Templates 


# AVVIO LA MACCHINA


Start-VM -VM $vm_new 


}


#Ricavo la tabella nomi macchina ip da mandare al gruppo patching

   Foreach ($vm in $servername) {
       $vm_new = $vm + "_" + "$baseline"
       get-vm -name $vm_new|Select name, @{N="IP Address";E={@($_.guest.IPAddress[0])}}|format-table -HIDETABLEHEADER -autosize

 
                                 }
    

