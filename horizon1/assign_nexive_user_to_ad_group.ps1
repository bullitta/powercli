<# Verifica la presenza di un user con entitlement dal pool nexive
al gruppo ad VDI-POOL-NEXIVE-PRODUZIONE

In caso non sia presente lo aggiunge al gruppo


.\assign_nexive_user_to_ad_group.ps1

#>



$ent = (get-hventitlement -resourcetype desktop -resourcename POOL-NEXIVE-PRODUZIONE).base.name
#seleziona tutti gli user del gruppo
 $members =    get-adgroupmember -identity VDI-POOL-NEXIVE-PRODUZIONE |Select -ExpandProperty Name


foreach ($e in $ent) {

if ($members -notcontains $e) {

      
      Add-ADGroupmember -Identity VDI-POOL-NEXIVE-PRODUZIONE -Members $e -Confirm:$false
      if ($? ) {
               Write-Host ($e + " has been added to ad group VDI-POOL-NEXIVE-PRODUZIONE" )
               }
     }

}

