$ts = Get-WmiObject -Class Win32_TerminalServiceSetting -Namespace "root\CIMV2\TerminalServices"
$RemainingDays = $ts.GetGracePeriodDays().DaysLeft
$RemainingDays
