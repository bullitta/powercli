<# Prende un parametro d'ingresso  obbligatorio


nome gruppo o user cui disassegnare il ruolo

e disassegna la permission associata  a tutti gli user/gruppi dell'elenco 
 su tutti i datacenter

esempio di utilizzo

.\deassign-a_role.ps1  -subject MailMx,"agrt\dfter"
testata solo per un user 
#>
param ([Parameter(Mandatory)]$subject)

$assign = @($subject.split(","))

#Creo l'entità cui deassegnare la nuova permission (tutti i datacenter)
$root = Get-Folder -name Datacenters 
Foreach ($sub in $assign) {

# identifica la permission da rimuovere
$permesso = Get-VIPermission -entity $root -principal $sub
if (-not $permesso)  { Write-Host "Nessuna Permission presente per $sub, verificare"
                       Exit
                  }
remove-vipermission -permission $permesso -confirm:$false


}