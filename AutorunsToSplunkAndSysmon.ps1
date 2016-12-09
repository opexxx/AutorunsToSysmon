<#
.Synopsis
   Creates sysmon and splunk configuration files for monitoring of changes to auto start extensibility points (aseps) 
   by transforming text-based output of sysinternals autoruns utility.
.DESCRIPTION
   For best results, ensure that all "Hide" options in autoruns are unchecked.
#>

#import the input
$input_file = 'C:\Users\David\Desktop\MOBILE-PC.txt'
$outfile_sysmon = ($env:TEMP + '\sysmon_autoruns_rules.xml')
$outfile_splunk = ($env:TEMP + '\splunk_autoruns_inputs.conf')
$input_lines = Get-Content $input_file

$outfile_sysmon | Remove-Item | Out-Null
$outfile_splunk | Remove-Item | Out-Null

$asep_locations = [System.Collections.ArrayList]@()
#transform the input
foreach ($line in $input_lines) {

    #exclude value entries
    if (($line.Substring(0,1) -ne '+') -and ($line.substring(0,1) -ne 'X') -and ($line.substring(0,4) -ne '"WMI') -and ($line.substring(0,15) -ne '"Task Scheduler') ) {

        # isolete the ASEP entry location from line
        $line = ([regex]'"(.+?)"').match($line).Groups[1].Value

        # only add unique values locations to array
        if ($asep_locations.Contains($line) -eq $false) {
            $asep_locations.Add($line) | Out-Null
        }
    }
}

$asep_locations = $asep_locations | Sort-Object

$Keys = [System.Collections.ArrayList]@()
$Files = [System.Collections.ArrayList]@()
$Folders = [System.Collections.ArrayList]@()

if ($asep_locations) {

    foreach ($entry in $asep_locations) {
        # identify registry type entries
        if ($entry -like 'HKLM*' -or $entry -like 'HKCU*') {

            # strip off hklm\hkcu prefix to keys
            $key = $entry
            $key = $key -replace '^HKCU\\','\'
            $key = $key -replace '^HKLM\\','\'

            # only add unique values to an array
            if ($keys.Contains($key) -eq $false) {
                $keys.Add($key) | Out-Null
            }
        }

        # identify file system entries
        if ($entry.Substring(1,2) -eq ':\') {

            # handle files vs. directories
            if ($entry.Substring($entry.Length - 4,1) -eq '.') {
                if ($Files.Contains($Files) -eq $false) {
                    $Files.Add($entry) | Out-Null
                }
            }
            else {
                if ($Folders.Contains($Folders) -eq $false) {
                    $Folders.Add($entry) | Out-Null
                }

            }

        }
    }

    if (Get-Item($outfile_sysmon) | Out-Null) {
        Remove-Item -path $outfile_sysmon -Force | Out-Null
    } 


    if (Get-Item($outfile_splunk) | Out-Null) {
        Remove-Item -path $outfile_splunk -Force | Out-Null
    }

    $keys = $keys | Sort-Object
    $Files = $Files | Sort-Object
    $Folders = $Folders | Sort-Object

    # output regkeys to Splunk
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

    # output files to Splunk
    $item = 0
    foreach ($file in $files) {
        $item++
        $file = $file -replace '\\Users\\\w+\\','\Users\*\'
        add-content -path $outfile_splunk -value ('')
        add-content -path $outfile_splunk -value ('[monitor://' + $file + ']')
        add-content -path $outfile_splunk -value ("index = main")
    }

    # output folders to Splunk
    $item = 0
    foreach ($folder in $folders) {
        $item++
        $folder = $folder -replace '\\Users\\\w+\\','\Users\*\'
        add-content -path $outfile_splunk -value ('')
        add-content -path $outfile_splunk -value ('[monitor://' + $folder + ']')
        add-content -path $outfile_splunk -value ("index = main")
    }


    # output regkeys to sysmon
    add-content -path $outfile_sysmon -value '<RegistryEvent onmatch="include">' 
    $keys = $keys | Sort-Object
    foreach ($key in $keys) {
        add-content -path $outfile_sysmon -value ("`t" + '<TargetObject condition="contains">' + $key + '</TargetObject>')
    }
    add-content -path $outfile_sysmon -value '</RegistryEvent>'

    # output files to sysmon
    $item = 0
    add-content -path $outfile_sysmon -value '<FileCreate onmatch="include">' 

    foreach ($file in $files) {
        $item++
        $file = $file -replace '\w:\\Users\\\w+',''
        add-content -path $outfile_sysmon -value ("`t" + '<TargetFilename condition="contains">' + $file + '</TargetFilename>')
    }

    foreach ($folder in $folders) {
        $item++
        $folder = $folder -replace '\w:\\Users\\\w+',''
        add-content -path $outfile_sysmon -value ("`t" + '<TargetFilename condition="contains">' + $folder + '</TargetFilename>')
    }


    add-content -path $outfile_sysmon -value '</FileCreate>'


    #open the files in notepad
    start-Process -FilePath ($env:windir + '\notepad.exe') -ArgumentList $outfile_sysmon
    start-Process -FilePath ($env:windir + '\notepad.exe') -ArgumentList $outfile_splunk
}

write-host ([string]$keys.Count + ' registry-based asep monitoring rules created.')
write-host ([string]$folders.Count + ' folder-based asep monitoring rules created.')
write-host ([string]$files.Count + ' folder-based asep monitoring rules created.')
