# lo script ricava l'elenco di tutti i trusted doamin
 lo salva in  un file chiamato c:\temp\Trusted_domain.csv


va lanciato in questo modo:

.\ricava-elenco-trusted-domain.ps1 


#>

GET-ADTRUST -filter * |select-object name,direction | out-file -FilePath c:\temp\Trusted_domain.csv