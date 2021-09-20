<#
  Lo SCRIPT elenca i nomi di tutti i gruppi in cui è stato inserito un utente
  Esempio di utilizzo
  .\get_ad_group_for_user.ps1 -user esx1  


#>
param ([Parameter(Mandatory)] $user)

Get-ADPrincipalGroupMembership -identity $user|select name