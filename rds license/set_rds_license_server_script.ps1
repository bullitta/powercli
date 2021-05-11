param ([Parameter(Mandatory)]$servername)

$obj = gwmi -namespace "Root\CIMV2\TerminalServices" Win32_TerminalServiceSetting
$obj.AddLSToSpecifiedLicenseServerList([in] string $servername)