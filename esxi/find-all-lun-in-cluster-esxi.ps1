<# script ricavato da questo link

https://www.lucd.info/2010/04/09/lun-report-datastores-rdms-and-node-visibility/

va lanciato in questo modo:

.\find-all-lun-in-cluster-esxi.ps1 <nome cluster>

Produce un file csv con l'elenco di tutte le lun id e del loro utilizzo sia come raw disk che come datastore

#>

param ($clusName,$csvName=("C:\temp\" + $clusName + "-LUN.csv"))

$rndNum = Get-Random -Maximum 99999
 
$LunInfoDef = @"
	public string ClusterName;
	public string CanonicalName;
	public string UsedBy;
	public string SizeMB;
"@
$LunInfoDef = "public struct LunInfo" + $rndNum + "{`n" + $LunInfoDef
 
$esxServers = Get-Cluster $clusName | Get-VMHost | Sort-Object -Property Name
$esxServers | %{
	$LunInfoDef += ("`n`tpublic string " + ($_.Name.Split(".")[0]) + ";")
}
$LunInfoDef += "`n}"
 
Add-Type -Language CsharpVersion3 -TypeDefinition $LunInfoDef
 
$scsiTab = @{}
$esxServers | %{
	$esxImpl = $_
 
# Get SCSI LUNs
	$esxImpl | Get-ScsiLun | where {$_.LunType -eq "Disk"} | %{
 
		$key = $esxImpl.Name.Split(".")[0] + "-" + $_.CanonicalName.Split(".")[1]
		if(!$scsiTab.ContainsKey($key)){
 
			$scsiTab[$key] = $_.CanonicalName,"",$_.CapacityMB
		}
	}
 
# Get the VMFS datastores
	$esxImpl | Get-Datastore | where {$_.Type -eq "VMFS"} | Get-View | %{
		$dsName = $_.Name
		$_.Info.Vmfs.Extent | %{
			$key = $esxImpl.Name.Split(".")[0] + "-" + $_.DiskName.Split(".")[1]
			$scsiTab[$key] = $scsiTab[$key][0], $dsName, $scsiTab[$key][2]
		}
	}
}
 
# Get the RDM disks
Get-Cluster $clusName | Get-VM | Get-View | %{
	$vm = $_
	$vm.Config.Hardware.Device | where {$_.gettype().Name -eq "VirtualDisk"} | %{
		if("physicalMode","virtualmode" -contains $_.Backing.CompatibilityMode){
			$disk = $_.Backing.LunUuid.Substring(10,32)
			$key = (Get-View $vm.Runtime.Host).Name.Split(".")[0] + "-" + $disk
			$scsiTab[$key][1] = $vm.Name + "/" + $_.DeviceInfo.Label
		}
	}
}
 
$scsiTab.GetEnumerator() | Group-Object -Property {$_.Key.Split("-")[1]} | %{
	$lun = New-Object ("LunInfo" + $rndNum)
	$lun.ClusterName = $clusName
	$_.Group | %{
		$esxName = $_.Key.Split("-")[0]
		$lun.$esxName = "ok"
		if(!$lun.CanonicalName){$lun.CanonicalName = $_.Value[0]}
		if(!$lun.UsedBy){$lun.UsedBy = $_.Value[1]}
		if(!$lun.SizeMB){$lun.SizeMB = $_.Value[2]}
 
	}
	$lun
} | Export-Csv $csvName -NoTypeInformation -UseCulture
Invoke-Item $csvName
