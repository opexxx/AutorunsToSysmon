
<#
.Synopsis
   Creates sysmon configuration xml for monitoring of autorun registry keys
   version 1.0.0
#>

# path to autoruns (todo: make $autoruns path dynamic based on prompt for user input)
$autoruns = 'c:\users\david\documents\development\projects\AutorunsToSysmon\autorunsc64.exe'
$arguments = '-nobanner -a * -ct'
$tmpfile = ($env:TEMP + '\autoruns_results.csv')

# run autoruns and write stdout to CSV
start-Process -FilePath $autoruns -ArgumentList $arguments -RedirectStandardOutput $tmpfile

# read CSV into object and dedup entry locations
$entries = Import-Csv -Path $tmpfile -Delimiter "`t" | Select-Object -Property 'Entry Location' -Unique

foreach ($entry in $entries) {
    # further reduce list to only include registry type entries
    if ($entry.'Entry Location' -like 'HKLM*' -or $entry.'Entry Location' -like 'HKCU*') {
        # ok, here's we're we now start to transform.  going to bed now
        Write-Host $entry.'Entry Location'
    }
}
