
$events = Get-WinEvent -FilterHashtable @{
    ProviderName = "Microsoft-Windows-VHDMP"
    ID = 1, 2, 12
}

$eventTable = foreach ($event in $events) {
    # Define a helper function to convert a hexadecimal string to Int64
    function Convert-HexToInt64($value) {
        $convertedValue = $null
        try {
            $convertedValue = [Convert]::ToInt64($value, 16)
        } catch {
            Write-Host "Failed to convert hexadecimal value: $value"
        }
        return $convertedValue
    }

    # Extract the VHD file path and file name from the description using regular expressions
    $description = $event.Message
    $vhdFilePath = $null
    $vhdFileName = "N/A"

    if ($description -match 'VHD File Path:\s*(.+?)\s*\r?\n') {$vhdFilePath = $Matches[1]}

    if ($description -match 'VHD File Name:\s*(.+?)\s*\r?\n') {$vhdFileName = $Matches[1]}

    $vhdmetaops = if ($event.Id -in 1, 2) { $event.Properties[3].Value } else { "N/A" }

    # Create a custom object with the desired properties for each event
    [PSCustomObject]@{
        'EventID'           = $event.Id
        'Description'       = $description
        'Time Created'      = $event.TimeCreated
        'RecordID'          = $event.RecordId
        'Level'             = $event.LevelDisplayName
        'Task'              = $event.TaskDisplayName
        'Opcode'            = $event.OpcodeDisplayName
        'Security UserID'   = $event.Properties[2].Value
        'Vhd Meta Ops'      = if ($event.Id -in 1, 2) { $event.Properties[3].Value } else { "N/A" }
        'Status'            = if ($event.Id -eq 12) { $event.Properties[4].Value } else { "N/A" }
        'VHD File Name'     = $event.Properties[1].Value
        'VHD Disk Number'   = if ($event.Id -eq 2) { $event.Properties[5].Value } else { "N/A" }
        'VHD File Path'     = $vhdFilePath
        'Computer'          = $event.MachineName
        'Channel'           = $event.LogName
        #'Version'           = $event.Version
        #'Correlation'       = $event.ActivityId
        #'Keywords'          = $event.Keywords
    }

    Write-Host $event.Id "|" $event.TimeCreated "|" $event.Properties[1].Value "|" $vhdmetaops

}

# Display the table in an Out-GridView window
# $eventTable | Out-GridView 

# This outputs the location of the iso file
# Write-Host $event.Properties[1].Value
