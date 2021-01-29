<# Prende un parametro d'ingresso  obbligatorio


nome dell'eseguibile associato all'applicazione
e genera un elenco di tutte le applicazioni che utilizzano quell'eseguibile

esempio di utilizzo

.\find-applications.ps1  -e "SAP logon"
testata solo una volta
#>



param ([Parameter(Mandatory)]$exename )

$all_app = get-hvapplication


Foreach ($app in $all_app) {

if ($app.executiondata.executablepath -match $exename) { 
              $app.data.name              
                write-host "      " -nonewline
                $app.executiondata.executablepath}


}
