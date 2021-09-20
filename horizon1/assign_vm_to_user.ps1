<# Prende tre parametri d'ingresso  obbligatori


nome della vm
nome dell'user 
nome del dominio
e assegna la vm ll'user

.\asssign_vm_to_user.ps1 -v djej -u aldo

#>

param ([Parameter(Mandatory)]$vm, [Parameter(Mandatory)]$user, [Parameter(Mandatory)]$domain )


$verifieduser = get-aduser -filter 'name -like $user'


if (!$verifiedUser) {Write-Host "User non presente su AD"

                       exit

                       }
                       else {$user = $domain + "\" + $user}



$verifiedMachine = get-hvmachine -machinename $vm

if (!$verifiedMachine) {Write-Host "Vm $machine non presente su vcenter"

                       exit

                       }




set-hvmachine -machinename $verifiedMachine.base.name -user $user


