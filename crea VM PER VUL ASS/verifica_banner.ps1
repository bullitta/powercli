<# Script per la verifica del contenuto dei banner delle macchine che superano i test
   VA
   Serve per sostituire i banner corretti e a seconda del sis op agisce su
    redhat : modifica del file /etc/profile.d/motd.sh
   Prende tre parametri d'ingresso
   1) l'elenco dei nomi delle vm che    devono essere verificate
   2) password di accesso dell'user amministrativo delle singole macchine
   3) la baseline di riferimento
   Esempio di utilizzo
   .\verifica_banner.ps1 -server agag,prod -pwd shshj1 -baseline 2020_T2
#>

param ([Parameter(Mandatory)]$server, [Parameter(Mandatory)]$pwd,[Parameter(Mandatory)]$baseline )

$servername = @($server.split(","))

$reference_string = "BASELINE:$baseline"


Foreach ($vm in $servername) {

if (($vm -match "RHEL") -or ($vm -match "SLES")) {

                      GET-VM -name $vm|copy-vmGuestFile -guestToLocal -source "/etc/profile.d/motd.sh" -destination ".\$vm-banner" -Guestuser root -guestpassword $pwd -Confirm:$false
          $content = get-content ".\$vm-banner" |select-string  -Pattern $reference_string
           
          if (-not $content) {
                  (get-content -path ".\$vm-banner") -replace "BASELINE:(.*)", "BASELINE:$baseline`""|set-content -path ".\$vm-banner"
                  GET-VM -name $vm|copy-vmguestFile -LocalToGuest -source ".\$vm-banner" -Destination "/etc/profile.d/motd.sh" -guestuser root -guestpassword $pwd -confirm:$false -force
                   }          
          }

}