<# Prende QUATTRO parametri d'ingresso tutti obbligatori

datastore nome del datastore in cui si trovano le VDI ogggetto dell'aggiornamento
cpu numero delle cpu delle VDI della farm
mem ram in GB delle VDI della farm
date giorno in cui avviene l'aggiornamento scritto come "mm/gg/aaaa"

e cerca di individuare in maniera univoca il cp-replica in corso di creazione a seguito di un operazione di 
push image su un desktop-pool o su una RDSH farm

esempio di utilizzo

.\find-cp-replica.ps1 -datastore ASERl -cpu 8 -mem 32 -date "12/07/2020"
testata solo una volta
#>

param ([Parameter(Mandatory)]$datastore,[Parameter(Mandatory)]$cpu, [Parameter(Mandatory)]$mem, [Parameter(Mandatory)]$date )

$VM = Get-VM -name cp-replica* -datastore $datastore

if (-not $VM) { Write-Host "nessun cp-replica presente nel datastore, verificare"
                   Exit
                  }

$VM_tested =  @()

Foreach ($virt in $VM) {



# PROVO a selezionare la cp-replica in base al num delle cpu e alla ram delle VDI originali

if ($virt.numcpu -eq $cpu -and $virt.memoryGB -eq $mem) {
                                        
                                        $VM_tested = $VM_tested + $virt
                                        
                                                       }

}




if ($VM_tested.length -eq 1) { Write-Host "aggiornamento in corso su: 
                             $VM_tested"
                             Exit
                             }

 $VM_tested2 = @()
 Foreach ($virt in $VM_tested) {
 $trovato = $virt|GET-VIEVENT |WHERE-OBJECT CREATEDTIME -MATCH $date
 if ( $trovato ) {$VM_tested2 = $VM_tested2 + $virt}
}
if ($VM_tested2.length -eq 1) { Write-Host "aggiornamento in corso su:"
                               $VM_tested2.name
                               
                              }

