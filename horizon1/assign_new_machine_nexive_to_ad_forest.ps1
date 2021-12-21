<# Calcola il nome delle macchine da utilizzare 
sul pool nexive, e aggiunge le macchine all'active direcotry 

Prende QUATTRO parametri d'ingresso  obbligatori


nome del frazionario
STRINGA del path da adoperare nel comando newadcomputer
nome dell'user adoperato su horizon 
password dell'user adoperato su horizon



Esempio di utilizzo

.\assign_new_machine_nexive_to_ad_forest.ps1 -f asr -O path  -a domain\user -p password

#>

param ([Parameter(Mandatory)] $frazionario, [Parameter(Mandatory)]$OUpath, [Parameter(Mandatory)]$admin, [Parameter(Mandatory)]$password )


#ricava le credenziali dell'user admin
$user = $admin
#$pword = ConvertTo-SecureString -String $password -AsPlainText -force
$pword = ConvertTo-SecureString  $password -AsPlainText -force
$c = new-object -typename System.Management.Automation.PSCredential -ArgumentList $user,$pword

#Calcola i nomi macchina

foreach ($f in $frazionario) {
#Calcola i nomi macchina
#parte del frazionario da usare nei nomi macchina
$fraz = $f.toString()
$fraz = $fraz.substring(1,4)
$base_machine_name = "TRM" + $fraz + "C" 
$search_machine = $base_machine_name + "*"

#Verifico la presenza di altre macchine con nomenclatura simile
$machine = Get-HVMachine -machinename $search_machine
if ($machine.length -gt 1) {
#$machine.base.name
#Se  esiste più di una macchina con quel pattern, ricava da che numero partire per la creazione dei nomi

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

  $machine_name = $base_machine_name +  $base_num; 

  $machine_name
  #$c.UserName
  

  NEW-ADCOMPUTER -NAME $machine_name -SAMACCOUNTNAME $machine_name -PATH $path -ENABLED $TRUE -CREDENTIAL $c
  }