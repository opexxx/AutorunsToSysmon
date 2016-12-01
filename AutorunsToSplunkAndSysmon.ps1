
<#
.Synopsis
   Creates sysmon configuration xml for monitoring of autorun registry keys
   version 1.2.0
#>

# path to autoruns (todo: make $autoruns path dynamic based on prompt for user input)
$autoruns = 'C:\Users\David\Downloads\SysinternalsSuite\autorunsc.exe'
$arguments = '-nobanner -a * -ct'
$tmpfile = ($env:TEMP + '\autoruns_results.csv')
$outfile_sysmon = ($env:TEMP + '\sysmon_autoruns_rules.xml')
$outfile_splunk = ($env:TEMP + '\splunk_autoruns_inputs.conf')

# run autoruns and write stdout to CSV
write-host ('Launching ' + $autoruns + ' with arguments ' + $arguments)
#start-Process -FilePath $autoruns -ArgumentList $arguments -RedirectStandardOutput $tmpfile -Wait

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

    if (Get-Item($outfile_sysmon)) {
        Remove-Item -path $outfile_sysmon -Force | Out-Null
    } 

    if (Get-Item($outfile_splunk)) {
        Remove-Item -path $outfile_splunk -Force | Out-Null
    }

    $keys = $keys | Sort-Object

    # output to Splunk
    $item = 0
    foreach ($key in $keys) {
        $item++
        $key = $key -replace '\\','\\'
        add-content -path $outfile_splunk -value ('')
        add-content -path $outfile_splunk -value ('[WinRegMon://autoruns_entry_' + $item + ']')
        add-content -path $outfile_splunk -value ('hive = .*' + $key + '.*')
        add-content -path $outfile_splunk -value ("disabled = false")
        add-content -path $outfile_splunk -value ("proc = .*")
        add-content -path $outfile_splunk -value ("type = set|create|delete|rename")
        add-content -path $outfile_splunk -value ("baseline = 0")
        add-content -path $outfile_splunk -value ("index = main")
    
    }

    # output to sysmon

    add-content -path $outfile_sysmon -value '<RegistryEvent onmatch="include">' 
    $keys = $keys | Sort-Object
    foreach ($key in $keys) {
        add-content -path $outfile_sysmon -value ("`t" + '<TargetObject condition="contains">' + $key + '</TargetObject>')
    }
    add-content -path $outfile_sysmon -value '</RegistryEvent>'

    #open the file in notepad
    start-Process -FilePath ($env:windir + '\notepad.exe') -ArgumentList $outfile_sysmon
    start-Process -FilePath ($env:windir + '\notepad.exe') -ArgumentList $outfile_splunk
}

