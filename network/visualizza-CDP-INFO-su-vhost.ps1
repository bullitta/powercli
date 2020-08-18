<# visualizza le CDP (cISCO Discovery Protocol) info
   su una serie di host esxi
   Prende come parametro d'ingresso l'elenco degli host
   da esaminare e produce un file contenente le informazioni
   esempio di utilizzo:
   .\visualizza-cdp-info-su-vhost.ps1 -server esxi1,esxi2
#>

param ([Parameter(Mandatory)]$server)

$servername = @($server.split(","))


foreach ($esxi in $servername) {
                        $esxi
                        $VMhost = get-vmhost -name $esxi
                        $NetSystem = get-view $VMhost.ExtensionData.Configmanager.NetworkSystem
                        foreach ($Pnic in $VMHost.ExtensionData.Config.Network.Pnic) {
                           $Pnic.Device
                           $PnicInfo = $NetSystem.QueryNetworkHint($Pnic.Device)
                           $PnicInfo.ConnectedSwitchPort
                           }
                    

                        
                            write-host "####################----#############"
                            write-host "####################----#############"
                                                 
                                 
                               
                            }


