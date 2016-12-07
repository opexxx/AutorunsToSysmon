
Synopsis:
-----------------------------------

Creates sysmon and splunk configuration files for monitoring of changes to auto start extensibility points (aseps) by transforming text-based output of sysinternals autoruns utility.

![alt tag](https://github.com/dstaulcu/AutorunsToSysmon/blob/master/Capture.JPG)

Usage:  
-----------------------------------
powershell.exe -file .\AutorunsToSplunkAndSysmon.ps1

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
