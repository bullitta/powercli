<# Prende tre parametri d'ingresso  obbligatori


cpu numero delle cpu delle VDI della farm
mem ram in GB delle VDI della farm
date giorno in cui avviene l'aggiornamento scritto come "mm/gg/aaaa hh"

e cerca di individuare in maniera univoca il cp-template creato a seguito di un operazione di 
push image su un desktop-pool o su una RDSH farm

esempio di utilizzo

.\find-cp-template.ps1  -cpu 8 -mem 32 -date "12/07/2020 09"
testata solo una volta
#>

param ([Parameter(Mandatory)]$cpu, [Parameter(Mandatory)]$mem, [Parameter(Mandatory)]$date )

$VM = Get-VM -name cp-template*

$VM_tested =  @()

Foreach ($virt in $VM) {



# PROVO a selezionare il cp-template in base al num delle cpu e alla ram delle VDI originali

if ($virt.numcpu -eq $cpu -and $virt.memoryGB -eq $mem) {
                                        
                                        $VM_tested = $VM_tested + $virt
                                        
                                                       }

}




if ($VM_tested.length -eq 1) { Write-Host "aggiornamento in corso su:" 
                             $VM_tested.name
                             Exit
                             }


 $VM_tested2 = @()
 Foreach ($virt in $VM_tested) {
 # Secondo tentativo, provo a selezionare il cd-template in base al giorno e all'ora in cui ho lanciato 
 #l'operazione
 $trovato = $virt|GET-VIEVENT |WHERE-OBJECT CREATEDTIME -MATCH $date
 if ( $trovato ) {$VM_tested2 = $VM_tested2 + $virt}
}


if ($VM_tested2.length -eq 1) {write-host ("trovato template:")
                                $VM_tested2.name
                                }