<#
Script integrato per l'esecuzione dei seguenti blocchi di operazioni:



1) spegnimento della vm e rimozione di tutti i dischi tranne quelli in cui si trova il s.o.
   tramite script: togli_hdisk_a_vm_a_parte_quelli_indicati.ps1

2) clone della vm 
     tramite script: clona_vm1.ps1
3) verifica dello stato del clone (tramite avvio senza rete)
   tramite script prova_stato_clone_vm.ps1

4) riassegnazione dei dischi alla vm di origine e riavvio
      Tramite script riassegna_hdisk_to_vm_$vm.ps1

A monte di tutte queste operazioni la macchina viene spenta e alla fine riaccesa

Prende tre parametri dingresso

1) nome macchina su cui deve essere eseguito il clone
2) elenco dischi da NON de-assegnare ri-assegnare
3)suffisso da utilizzare per il nome del clone

esempio d'uso

.\Clone_a_freddo_con_rimozione_dischi_non_sitema.ps1 -server shsh -disk "Hard disk 1" -suffix 3121

#>


param ([Parameter(Mandatory)]$server,[Parameter(Mandatory)]$disk, [Parameter(Mandatory)]$suffix)

get-vm -name $server|Stop-vm -Confirm:$false


cd "..\hard disk"
.\togli_hdisk_a_vm_a_parte_quelli_indicati.ps1 -server $server -disk $disk



cd "..\clona vm"
.\clona_vm1.ps1 -server $server -suffix $suffix

$clone = $server + "_" + $suffix

.\prova_stato_clone_vm.ps1 -server $clone

cd "..\hard disk"
& ".\riassegna_hdisk_to_vm_$server.ps1"


get-vm -name $server|Start-vm -Confirm:$false




