#prende due parametri d'ingresso tutti obbligatori
#  1)elenco nomi template delle macchine da creare
#  2)suffisso da inserire nel nome delle macchine 
# esempio di lancio:
#    .\create_vm_for_Vuln_Ass.ps1 -s RHEL74,WIN2016-MIDDL,WIN2012 -b 2020_T1
#
#  Crea nuove vm a partire da template presenti nel vcenter
# sempre per proseguire nell'esempio verranno create le vm:
# RHEL74_2020_T1,WIN2016-MIDDL_2020_T1,WIN2012_2020_T1


param ([Parameter(Mandatory)]$server,[Parameter(Mandatory)]$baseline)

$Cluster = Get-Cluster -Name S_TO_COMP

$servername = @($server.split(","))


Foreach ($vm in $servername) {

#Ricavo il datastore da utilizzare 
# seleziona i datastore con multipath visibili al cluster che non contengono BCK, REPL, ....nel nome

$ESXI =  GET-VMHOST -ID (GET-TEMPLATE -NAME $vm).HOSTID

$cluster = Get-cluster -vmHOST $ESXI

<##
# Questa parte è stata commentata perchè su sviluppo i template per convenzione devono
# stare su un datastore denominato *_SHARED

$Datastore = $Cluster|get-datastore | where {$_.ExtensionData.Summary.MultipleHostAccess -eq 'true'}|sort-object -Property freespacegb -descending|select name

$valid_datastore = @()

$Datastore|foreach {if ($_ -NOTmatch "BCK" -and $_ -NOTMatch "REPL" -and $_ -NOTMatch "SRM" -and $_ -notmatch "library" -and $_ -notmatch "NAS") {
                                                                     $name = @("$_".split('='))
                                                                     $nome = $name[1].Substring(0,$name[1].Length-1)
                                                                     $valid_datastore += "$nome"
                                                                     }
                       }

#Questa parte serve a bypassare il problema della presenza di nomi  duplicati dei datastore (stesso nome ma id diverso)
$dstoreid = @($Cluster|get-datastore -name $valid_datastore[0])
$dstore = get-datastore -id $dstoreid[0].id

#>

$dstore = get-datastore|where name -match "_SHARED"





$vm_new = $vm + "_" + "$baseline"






#creo la VM dal template

New-VM -Name $vm_new -Template $vm -ResourcePool $Cluster -Datastore $dstore



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
    

