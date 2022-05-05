<#

DA TESTARE sembra che il comando net user non venga eseguito, in realtà funziona
  prende tre parametri d'ingresso:

  elenco macchine in cui effettuare il cambio password dell'user administrator
  password per accedere alle macchine
  nuova password per l'user administrator

  

  
  Esempio di utilizzo

  .\change_administrator_password.ps1 -s name2,name3 -p primo n secondo

#>

param ([Parameter(Mandatory)]$servername,[Parameter(Mandatory)]$password,[Parameter(Mandatory)]$newpassword )



Foreach ($server in $servername) {

$vm = get-vm -name $server|where-object {$_.powerstate -eq "PoweredOn"}



 
  #Lancia il comando che modifica la password
  $output = Invoke-vmscript -vm $vm -scriptText "net user administrator $newpassword" -Guestuser "administrator" -guestpassword $password
  $outputchomped = $output.scriptoutput -replace "\n",""
  write-host ($server + ":  " + $outputchomped)

 
}