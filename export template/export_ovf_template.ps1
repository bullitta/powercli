<# 
   questo script esporta i template delle vm in formato ovf o ova

   Prende due parametri d'ingresso tutti obbligatori
   1) elenco template da esportare
   2) directory di destinazione dei file ovf o ova
   3) formato per l'export, ovf o ova
  

   esempio di utilizzo:

   .\export_template.ps1 -t WIN2012,WIN2012-ORACLEDB121,RHEL76 -d c:\test -f ova

   NOTA: 

#>

param ([Parameter(Mandatory)]$template,[Parameter(Mandatory)]$destination,[Parameter(Mandatory)]$format )

$templatename = @($template.split(","))

Foreach ($vm in $templatename) {

$VirtM = Get-VM -name $vm


#$destinazione = $destination + "\" + $vm



export-vapp -destination $destination -vm $VirtM -format $format

}