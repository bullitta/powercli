<# Prende due parametri d'ingresso entrambi obbligatori

nome ruolo
nome gruppo o user cui assegnare il ruolo

e assegna il ruolo indicato a tutti gli user/gruppi dell'elenco al secondo parametro
 su tutti i datacenter

esempio di utilizzo

.\assign-a_role.ps1 -role stert -subject MailMx,"agrt\dfter"
testata solo per un user 
#>
param ([Parameter(Mandatory)]$role,[Parameter(Mandatory)]$subject)

$assign = @($subject.split(","))
$ruolo = get-virole -name $role
if ( -not $ruolo) { Write-Host "Ruolo non presente nel vcenter, verificare"
                   Exit
                  }
#Creo l'entità cui assegnare la nuova permission (tutti i datacenter)
$root = Get-Folder -name Datacenters 
Foreach ($sub in $assign) {

# crea una nuova permission e assegnala 
new-vipermission -entity $root  -role $ruolo  -principal $sub -propagate:$true


}