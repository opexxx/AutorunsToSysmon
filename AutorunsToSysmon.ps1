
<#
.Synopsis
   Creates sysmon configuration xml for monitoring of autorun registry keys
   version 1.0.0
#>

# path to autoruns (todo: make $autoruns path dynamic based on prompt for user input)
$autoruns = 'c:\users\david\documents\development\projects\AutorunsToSysmon\autorunsc64.exe'
$arguments = '-nobanner -a * -ct'
$tmpfile = ($env:TEMP + '\autoruns_results.csv')
$outfile = ($env:TEMP + '\sysmon_autoruns_rules.xml')

# run autoruns and write stdout to CSV
write-host ('Launching ' + $autoruns + ' with arguments ' + $arguments)
start-Process -FilePath $autoruns -ArgumentList $arguments -RedirectStandardOutput $tmpfile -Wait

# read CSV into object and dedup entry locations
$entries = Import-Csv -Path $tmpfile -Delimiter "`t" | Select-Object -Property 'Entry Location' -Unique


$Keys = [System.Collections.ArrayList]@()

if ($entries) {

    foreach ($entry in $entries) {
        # further reduce list to only include registry type entries
        if ($entry.'Entry Location' -like 'HKLM*' -or $entry.'Entry Location' -like 'HKCU*') {

            # strip off hklm\hkcu prefix to keys
            $key = $entry.'Entry Location'
            $key = $key -replace '^HKCU\\','\'
            $key = $key -replace '^HKLM\\','\'

            # only add unique values to an array
            if ($keys.Contains($key) -eq $false) {
                $keys.Add($key) | Out-Null
            }
        }
    }

    #write the output to file
    if (Get-Item($outfile)) {
        Remove-Item -path $outfile -Force
    }

    add-content -path $outfile -value '<RegistryEvent onmatch="include">' 
    $keys = $keys | Sort-Object
    foreach ($key in $keys) {
        add-content -path $outfile -value ("`t" + '<TargetObject condition="contains">' + $key + '</TargetObject>')
    }
    add-content -path $outfile -value '</RegistryEvent>'

    #open the file in notepad
    start-Process -FilePath ($env:windir + '\notepad.exe') -ArgumentList $outfile
}

