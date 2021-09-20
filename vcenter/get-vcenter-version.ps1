<#
  prende un parametro d'ingresso:

  elenco macchine vcenter su cui effettuare la verifica
  
  
  
  Esempio di utilizzo

  .\get-vcenter-version.ps1 -v name2,name2 
  e produce il file elenco_vcenter.csv
#>
param ([Parameter(Mandatory)]$vcenter )
# disabilita la stringa di risposta alla connessione
#Set-PowerCLIConfiguration -scope user -ParticipateInCeip $false

foreach ($vc in $vcenter) {

connect-viserver -server $vc
$dati = $Global:Defaultviserver|select name,version,build
disconnect-viserver -server $vc -force -confirm:$false
$line = $dati.name + "; " + $dati.version + "; " + $dati.build
Out-File -FilePath elenco-vcenter.csv -append -InputObject $line
}