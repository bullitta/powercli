connect-viserver -viserver pvdivcas01v.rete.poste
$instance = get-vm -name FARMTESTAVAYA01
Invoke-vmscript -vm $instance -scriptText Get-WmiObject -Class Win32_TermialServiceSettings -Namespace "root\CIMV2\TerminalServices" -Guestuser administrator -Guestpassword Pegasus1
Invoke-vmscript -vm $instance -scriptText $ts.GetGracePeriodDays().DaysLetf -Guestuser administrator -GuestpasswordPegasus1
$instance = get-vm -name provagenesis01
Invoke-vmscript -vm $instance -scriptText Get-WmiObject -Class Win32_TermialServiceSettings -Namespace "root\CIMV2\TerminalServices" -Guestuser administrator -Guestpassword Pegasus1
Invoke-vmscript -vm $instance -scriptText $ts.GetGracePeriodDays().DaysLetf -Guestuser administrator -GuestpasswordPegasus1
$instance = get-vm -name PVDIRDS01
Invoke-vmscript -vm $instance -scriptText Get-WmiObject -Class Win32_TermialServiceSettings -Namespace "root\CIMV2\TerminalServices" -Guestuser administrator -Guestpassword Pegasus1
Invoke-vmscript -vm $instance -scriptText $ts.GetGracePeriodDays().DaysLetf -Guestuser administrator -GuestpasswordPegasus1
$instance = get-vm -name PVDIRDSHSAC01
Invoke-vmscript -vm $instance -scriptText Get-WmiObject -Class Win32_TermialServiceSettings -Namespace "root\CIMV2\TerminalServices" -Guestuser administrator -Guestpassword Pegasus1
Invoke-vmscript -vm $instance -scriptText $ts.GetGracePeriodDays().DaysLetf -Guestuser administrator -GuestpasswordPegasus1
$instance = get-vm -name PVDIRDSHSAP01
Invoke-vmscript -vm $instance -scriptText Get-WmiObject -Class Win32_TermialServiceSettings -Namespace "root\CIMV2\TerminalServices" -Guestuser administrator -Guestpassword Pegasus1
Invoke-vmscript -vm $instance -scriptText $ts.GetGracePeriodDays().DaysLetf -Guestuser administrator -GuestpasswordPegasus1
$instance = get-vm -name PVDIRDSHAFO01
Invoke-vmscript -vm $instance -scriptText Get-WmiObject -Class Win32_TermialServiceSettings -Namespace "root\CIMV2\TerminalServices" -Guestuser administrator -Guestpassword Pegasus1
Invoke-vmscript -vm $instance -scriptText $ts.GetGracePeriodDays().DaysLetf -Guestuser administrator -GuestpasswordPegasus1
$instance = get-vm -name PVDIRDSHRUO01
Invoke-vmscript -vm $instance -scriptText Get-WmiObject -Class Win32_TermialServiceSettings -Namespace "root\CIMV2\TerminalServices" -Guestuser administrator -Guestpassword Pegasus1
Invoke-vmscript -vm $instance -scriptText $ts.GetGracePeriodDays().DaysLetf -Guestuser administrator -GuestpasswordPegasus1
$instance = get-vm -name PVDIRDSHSCCM01
Invoke-vmscript -vm $instance -scriptText Get-WmiObject -Class Win32_TermialServiceSettings -Namespace "root\CIMV2\TerminalServices" -Guestuser administrator -Guestpassword Pegasus1
Invoke-vmscript -vm $instance -scriptText $ts.GetGracePeriodDays().DaysLetf -Guestuser administrator -GuestpasswordPegasus1
$instance = get-vm -name PVDIRDSHSDESK01
Invoke-vmscript -vm $instance -scriptText Get-WmiObject -Class Win32_TermialServiceSettings -Namespace "root\CIMV2\TerminalServices" -Guestuser administrator -Guestpassword Pegasus1
Invoke-vmscript -vm $instance -scriptText $ts.GetGracePeriodDays().DaysLetf -Guestuser administrator -GuestpasswordPegasus1
$instance = get-vm -name provasap01
Invoke-vmscript -vm $instance -scriptText Get-WmiObject -Class Win32_TermialServiceSettings -Namespace "root\CIMV2\TerminalServices" -Guestuser administrator -Guestpassword Pegasus1
Invoke-vmscript -vm $instance -scriptText $ts.GetGracePeriodDays().DaysLetf -Guestuser administrator -GuestpasswordPegasus1
