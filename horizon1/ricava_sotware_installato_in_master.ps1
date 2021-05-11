<# Lo script esegue la sequenza di operazioni
 1)Ricava l'elenco dei nomi delle macchine  usate dai vari pool (una macchina per pool)
 2) si collega al vcenter e per ogni macchina ricava l'elenco del softwre installato    

 Esempio di utilizzo:

 .\ricava_sotware_installato_in_master.ps1 -s 10 -p ahahah -v stsr

#>

param ([Parameter(Mandatory)]$sisop,[Parameter(Mandatory)]$password,[Parameter(Mandatory)]$vcenter)
$elenco_vm = @()
#Ricavo tutti i desktop pool di tipo instant clone (gli unici presenti)
$iclone = @(GET-HVPOOL|WHERE-OBJECT {$_.source -eq 'INSTANT_CLONE_ENGINE'})
Foreach ($pool in $iclone) {
  if ($pool.AutomatedDesktopData.VirtualCenterNamesData.ParentVmPath -match "WINDOWS $sisop") 
    {
     $name_pattern = $pool.AutomatedDesktopData.VmNamingSettings.PatternNamingSettings.NamingPattern
     $array_name = $name_pattern.split("{")
     $nome_vm = $array_name[0]
     $array_name1 = $array_name[1].split("=")
     $numero =  $array_name1[1].substring(0,1)
    
     if ($numero -eq "2") {$nome_vm = $nome_vm + "01" }
     if ($numero -eq "3") {$nome_vm = $nome_vm + "001" }
     $elenco_vm = $elenco_vm += $nome_vm

    }

}
$elenco_vm

<#
connect-viserver -server $vcenter
$command = "Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table -AutoSize"
Foreach ($name in $elenco_vm) {
 $vm = get-vm -name $name
 if (-not $vm) {$name.substring(0,$name.length -1)
                $name = $name + "2"
                $vm = get-vm -name $name 
                }
 $output = Invoke-vmscript -vm $vm -scriptText "$command" -Guestuser "administrator" -guestpassword $password
 write-host($vm + ":   " + $output)

}
#>


