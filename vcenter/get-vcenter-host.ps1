<#
  prende un parametro d'ingresso:

  elenco macchine vcenter su cui effettuare la verifica
  
  
  
  Esempio di utilizzo

  .\get-vcenter-host.ps1 -v name2,name2 
  e produce il file elenco_vcenter-host.csv
#>

param ([Parameter(Mandatory)]$vcenter )
# disabilita la stringa di risposta alla connessione
#Set-PowerCLIConfiguration -scope user -ParticipateInCeip $false

foreach ($vc in $vcenter) {

connect-viserver -server $vc;
$vcname = $vc.split("{.}");
$dati = get-vm -name $vcname[0]|select name,vmhost;
$dati;
disconnect-viserver -server $vc -force -confirm:$false;
$line = $dati.name + "; " + $dati.vmhost.name;

Out-File -FilePath elenco_vcenter-host.csv -append -InputObject $line;
}