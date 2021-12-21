<# Da utilizzare per l'aggiunta di nuove vm e assegnazione user al pool nexive
in base al numero di frazionario

Prende due parametri d'ingresso  obbligatori


nome del frazionario
elenco degli user cui vanno assegnate le nuove macchine




Esempio di utilizzo

.\assign_new_machine_to_nexive_pool.ps1 -f asr -u ddkdk, kdkdk 

#>

# da completare parte che effettua il reset dei desktop creati

param ([Parameter(Mandatory)] $frazionario,[Parameter(Mandatory)]$user)

#elimina il  file di appoggio c:\temp\macchine_da_riavviare


remove-item c:\temp\macchine_da_riavviare

#parte del frazionario da usare nei nomi macchina
$fraz = $frazionario.toString()
$fraz = $fraz.substring(1,4)
$base_machine_name = "TRM" + $fraz + "C" 
$search_machine = $base_machine_name + "*"

#Verifico la presenza di altre macchine con nomenclatura simile

$machine = Get-HVMachine -machinename $search_machine

#Se  esiste più di una macchina con quel pattern, ricava da che numero partire per la creazione dei nomi

if ($machine.length -gt 1) {


 $num = $machine.base.name|sort
 
 $base = $num[$num.length -1].substring(8,3)
 
 #$pre_base = $num[$num.length -1].substring(8,2)
 $base_num = '{0:d3}' -f ([int] $base + 1)
 #$machine_name = "TRM" + $fraz + "C" + $pre_base  + $base_num
  }

# sE è presente solo una macchina ricava sempre il numero da cui partire

if ($machine.length -eq 1) {
   $base = ($machine.base.name).substring(8,3)
   $base_num = '{0:d3}' -f ([int] $base + 1)
 }
# Se non sono già presenti predisponi il nome completamnte in base al frazionario
if (-not $machine) {

   $base_num = '{0:d3}' -f [int] 1

  }



<#

$machine = Get-HVMachine -machinename $search_machine
#Se le macchine esistono, ricava da che numero partire per la creazione dei nomi
if ($machine) {
 $num = $machine.base.name|sort
 $base = $num[$num.length -1].substring(8,3)
 #$pre_base = $num[$num.length -1].substring(8,2)
 $base_num = '{0:d3}' -f ([int] $base + 1)
 #$machine_name = "TRM" + $fraz + "C" + $pre_base  + $base_num
  }
# Se non sono già presenti predisponi il nome completamnte in base al frzionario
if (-not $machine) {

   $base_num = '{0:d3}' -f [int] 1

  }
 # $base_num
  #>

#verifica se le utenze sono o meno già presenti negli entitlement del pool

foreach ($u in $user) {

$u = "rete.poste\" + $u

$ent = get-hventitlement -resourcetype desktop -resourcename POOL-NEXIVE-PRODUZIONE -user $u

if ($ent) {
             write-host ("User: " + $u + " già presente negli entitlement del pool POOL-NEXIVE-PRODUZIONE, verificare meglio")
             exit;
           }

#write-host ("prova")
}
# procedi alla creazione della macchine e all'assegnazione agli user

foreach ($u in $user) {



$machine_name = $base_machine_name +  $base_num; 


#popola il file macchine_da_riavviare
$machine_name |out-file -filepath c:\temp\macchine_da_riavviare

Add-HVDesktop -poolname  POOL-NEXIVE-PRODUZIONE -machines $machine_name -users $u

write-host ("User: " + $u + " assigned to new vm: " + $machine_name)

$base_num = '{0:d3}' -f ([int] $base_num + 1)

}


<#

#QUESTA parte è stata introdotta per superare il seg problema: alla fine dell'operazione di creazione rimane una sessione
#aperta dove l'user collegato è .\administrator

$elenco_macchine = get-content -path c:\temp\macchine_da_riavviare

#attebdi 20 min tempo medio di durata dell'autoconfig delle macchine
Start-sleep -s 720

foreach ($vm in $elenco_macchine) {
$machine = get-hvmachine -machinename $vm;
$stato = $machine.base.basicstate;
if ($stato -like  "Unassigned  user Connected") {reset-hvmachine -machinename $vm}
  else {write-host ("Non è stato possibile riavviare la macchina: " + $machine + "la macchina era in stato: " + $stato + " riprovare più tardi")}
}

#>

