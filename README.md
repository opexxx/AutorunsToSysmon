
Synopsis:
-----------------------------------
Creates sysmon configuration xml or splunk inputs.conf for monitoring of autorun registry key changes.  
Obtains list of autorun keys to monitor by transforming output of command line version of [sysinternals autoruns](https://technet.microsoft.com/en-us/sysinternals/bb963902). 

![alt tag](http://url/to/capture.jpg)

Usage:  
-----------------------------------
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

	1.2.0
	--------
	Added support for Splunk inputs.conf
	

AutorunsToSysmon Update History:
-----------------------------------

	1.0.0
	--------
	Initial version
