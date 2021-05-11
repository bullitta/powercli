<# Ricava l'elenco dei nomi delle macchine master usate dai vari pool come golden image
 
  esempio di utilizzo
    


#>

#Ricavo tutti i desktop pool di tipo instant clone (gli unici presenti)
$iclone = @(GET-HVPOOL|WHERE-OBJECT {$_.source -eq 'INSTANT_CLONE_ENGINE'})
write-host ("Nome Pool      Master           MACHINE-NAMES")
Foreach ($pool in $iclone) {

write-host ($pool.base.name + ":     " + $pool.AutomatedDesktopData.VirtualCenterNamesData.ParentVmPath + "         " + $pool.AutomatedDesktopData.VmNamingSettings.PatternNamingSettings.NamingPattern )
}
  
