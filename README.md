
Synopsis:
-----------------------------------
Creates sysmon configuration xml for monitoring of autorun registry keys

UserEventToSpeech Usage:  
powershell.exe -file .\AutorunsToSysmon.ps1

Requirements:
-----------------------------------

	Sysinternals autorunsc.exe
	Powershell execution enabled

Notes:
-----------------------------------
Executes autorunsc.exe, parses output, transforms to sysmon config file spec.

AutorunsToSysmon Update History:
-----------------------------------

	1.0.0
	--------
	Initial version
	

AutorunsToSysmon Update History:
-----------------------------------

	1.0.0
	--------
	Initial version