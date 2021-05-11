<#
  prende un parametro d'ingresso:

  nome del cluster

 analizza tutte le vm definite sul cluster per vedere il num di cpu assegnate e fa la somma
  
  Esempio di utilizzo

  .\get_num_cpu_used_in_cluster.ps1 -c cluster

#>

param ([Parameter(Mandatory)]$clustername)

$cluster = get-cluster -name $clustername

$ALL_VM = get-vm -Location $cluster

Foreach ($vm in $ALL_VM) {

$all_cpu_used = $all_cpu_used + $vm.NUMCPU

}

write-host "Num totale cpu assegnate a vm nel cluster $clustername"
write-host ($all_cpu_used)