<# prende due parametro d'ingresso:

elenco nomi  host, ambiente di riferimento

e ricava un elenco di proprietà dell'host 

FDN
ip
marca
modello
ambiente
version
build

che salva su un file con nome fisso c:\temp\esxi_prop.csv


esempio di utilizzo:
.\get_host_property.ps1 -e host,host3 -a "multidimensional ambient"




#>

param ($esxi,$csvName=("C:\temp\esxi_prop_temp.csv"), $ambiente)

# Per ogni esxi ricava un' array con le seg proprietà dell'esxi nome,marca,modello,versione,build
foreach ($esx in $esxi){
(get-vmhost -name $esx)|select-object name,manufacturer,model,version,build|ConvertTo-Csv -delimiter ';'   -NoTypeInformation > $csvName
$ip = (get-vmhost -name $esx).networkinfo.dnsaddress
$array_prop = get-content -Path $csvName
Remove-Item $csvName

foreach ($line in $array_prop) {
     # salta la riga dell'header
     if ($line -notmatch "Name") {
      
         # Aggiunge ai parametri gli ip in seconda posizione e l'ambiente in penultima
           $array_prop = $line.split(";")
          ($array_prop[0] + ";" + $ip + ";" + $array_prop[1]+ ";" + $array_prop[2] + ";" + $ambiente + ";" +  $array_prop[3] + ":" + $array_prop[4]) | out-file -FilePath "C:\temp\esxi_prop.csv" -Append
          }
         }
}