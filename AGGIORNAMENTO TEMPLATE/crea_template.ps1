<# LO script crea dei template a partire da un elenco di vm
I template avranno lo stesso nome della vm di partenza

esempio d'uso

.\crea_template.ps1 sert1,asert1

#>

param ([Parameter(Mandatory)]$server)

$servername = @($server.split(","))

Foreach ($vm in $servername) {
                              get-vm -name $servername|set-vm -ToTemplate -Confirm:$false                            


                            }
