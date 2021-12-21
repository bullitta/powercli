<# Da utilizzare per il recovery di vm in stato error




Esempio di utilizzo

.\recover_machine_in_error_status.ps1 

#>

function get_day_and_hour {
    param ([Parameter(Mandatory)]$vm);
   $dateString = $vm.ManagedMachineData.CloneErrorTime.tostring();
   $dateArray = $dateString.split(" ");
   $day = $dateArray[0];
   $time = $dateArray[1];
   $giorno = ($day.split("/"))[0]
   $ora = ($time.split(":"))[0]
   return  $giorno,$ora  


   }

#Ricavo l'elenco delle macchine con status error
$VmStatusError = Get-HVMachine|where {$_.base.BasicState -eq "error"}

foreach ($vm in $VmStatusError) {
           
         write-host ($vm.base.name + ":" + $vm.ManagedMachineData.CloneErrorMessage)

 #in base alla condizione di errore presente prevedere il rimedio

<#

if ($vm.ManagedMachineData.CloneErrorMessage -match "No host is compatible with the virtual machine") 
  {# stato non bloccante, horizon riesce a fare da solo il reset della vdi
  #write-host ($vm.base.name + ":" + $vm.ManagedMachineData.CloneErrorMessage)
  # reset-hvmachine -machinename $vm -confirm:$false
  }

#>

<#
if ($vm.ManagedMachineData.CloneErrorMessage -match  "The operation is not allowed in the current state of the host") {
   write-host ($vm.base.name + ":" + $vm.ManagedMachineData.CloneErrorMessage)
   $giorno_ora = get_day_and_hour($vm);
   <#
   #verifica se la vdi è in questo stato da più di un'ora e in caso lo sia procede al reset
   if (($giorno_ora[0] -le (get-date).day) -and ($giorno_ora[1] -lt (Get-Date).Hour)) {
         write-host ($giorno_ora[0] + " " +$giorno_ora[1] + " " + (get-date).Hour)
         reset-hvmachine -machinename $vm.base.name -confirm:$false
         }

       }

#>

<#
if ($vm.ManagedMachineData.CloneErrorMessage -match "The operation is not supported on the object") {

     write-host ($vm.base.name + ":" + $vm.ManagedMachineData.CloneErrorMessage)
     $giorno_ora = get_day_and_hour($vm);
     #verifica se la vdi è in questo stato da più di un'ora e in caso lo sia procede al delete
     if (($giorno_ora[0] -le (get-date).day) -or ($giorno_ora[1] -lt (Get-Date).Hour)) {
         write-host ($giorno_ora[0] + " " +$giorno_ora[1] + " " + (get-date).Hour)
        # remove-hvmachine -machinename $vm.base.name -deletefromdisk -confirm:$false
         }
       
    }
#>



     
if ($vm.ManagedMachineData.CloneErrorMessage -match "Instant Clone agent initialization state error" ) {

    # write-host ($vm.base.name + ":" + $vm.ManagedMachineData.CloneErrorMessage)
    <# $giorno_ora = get_day_and_hour($vm);
     #verifica se la vdi è in questo stato da più di un'ora e in caso lo sia procede al delete
     if (($giorno_ora[0] -le (get-date).day) -or ($giorno_ora[1] -lt (Get-Date).Hour)) {
         write-host ($giorno_ora[0] + " " +$giorno_ora[1] + " " + (get-date).Hour)
        # remove-hvmachine -machinename $vm.base.name -deletefromdisk -confirm:$false
         }
       #>  
    }   
if ($vm.ManagedMachineData.CloneErrorMessage -match "Customization operation timed out" ) {

    # write-host ($vm.base.name + ":" + $vm.ManagedMachineData.CloneErrorMessage)
    <# $giorno_ora = get_day_and_hour($vm);
     #verifica se la vdi è in questo stato da più di un'ora e in caso lo sia procede al delete
     if (($giorno_ora[0] -le (get-date).day) -or ($giorno_ora[1] -lt (Get-Date).Hour)) {
         write-host ($giorno_ora[0] + " " +$giorno_ora[1] + " " + (get-date).Hour)
        # remove-hvmachine -machinename $vm.base.name -deletefromdisk -confirm:$false
         }
        #> 
    }  
  
  
  
    
}