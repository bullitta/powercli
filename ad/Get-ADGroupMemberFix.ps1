<# definizione di funzione che risolve
un problema di get-adgroupmember (non funziona quando nel gruppo vi sono membri non appartenenti al dominio)

va richiamato in questo modo:

.\Get-ADGroupMemberFix.ps1 <nome gruppo di cui si vogliono ricavare i membri>
#>


Function Get-ADGroupMemberFix {
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        ) ]$Identity )
    process {
        foreach ($GroupIdentity in $Identity) {
        
            $Group = $null
            $Group = Get-ADGroup -Identity $GroupIdentity -Properties Member
            if (-not $Group) {
                continue
            }
            Foreach ($Member in $Group.Member) {
                Get-ADObject $Member 
                
            }
        }
    }
}

 write-host ("sono qui" + $Identity)

