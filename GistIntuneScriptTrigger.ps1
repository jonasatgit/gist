$Branch = "dev"
$Version = "v0.0.6"
$LatestAddition = "New Menu by https://github.com/jonasgit"
$Title = @"
GIST - Gist Intune Script Trigger $Version ($Branch) 
by https://x.com/MrWyss Source & Improvements: https://github.com/MrWyss-MSFT/gist
Latest addition: $LatestAddition
"@

$GistCatalog = @(
    [ordered]@{
        Name        = "Get-Win32AppsOrder"
        Category    = "Intune"
        Url         = "https://gist.githubusercontent.com/MrWyss-MSFT/c52f0a4567cba24e9ac8a38416a05bac/raw/cffeca3256e5c4c31fdd8b1cbaa8b86ced9833f5/Get-Win32AppsOrder.ps1"
        Description = "Reads the IntuneManagementExtension.log and returns a ordered list of the Win32Apps"
        Author      = "MrWyss-MSFT"
        Elevation   = $false
    }
    [ordered] @{
        Name        = "Get-CoMgmtWL"
        Category    = "CoMgmt"
        Url         = "https://gist.githubusercontent.com/MrWyss-MSFT/228ed9f3dd2b67077790a3bef98442d5/raw/51699848761c0625991ff1374f227f945e8f42cd/Get-CoMgmtWL.ps1"
        Description = "Returns if CoManagement is enabled and how the workloads are configured"
        Author      = "MrWyss-MSFT"
        Elevation   = $false
    }
    [ordered] @{
        Name        = "Get-AutopilotAndESPProgress"
        Category    = "Autopilot"
        Url         = "https://gist.githubusercontent.com/MrWyss-MSFT/d511d655f55762233a1d442c24d584f6/raw/6a508ad8ca7f7f5206365f699b9a8c25a01b2dd5/Get-AutopilotAndESPProgress.ps1"
        Description = "Script to view the Autopilot and ESP Progress"
        Author      = "MrWyss-MSFT"
        Elevation   = $false
    }
    [ordered] @{
        Name        = "Copy-AutoPilotHashToClipboard"
        Category    = "Autopilot"
        Url         = "https://gist.githubusercontent.com/MrWyss/b83733e8378139af6032381359e00803/raw/7f87d17406e7e120be25c6c35fe1fc154233f17e/Copy-AutoPilotHashToClipboard.ps1"
        Description = "Copy the Autopilot Hash to the clipboard"
        Author      = "MrWyss"
        Elevation   = $true
    }
    [ordered] @{
        Name        = "New-IntuneRegistryFavorites"
        Category    = "Intune"
        Url         = "https://gist.githubusercontent.com/MrWyss-MSFT/500b2270b0b23b2fdc9ddc78092c355d/raw/9e3237f26674e2b0ad69b585849797fb731da0f2/New-IntuneRegistryFavorites.ps1"
        Description = "Create Registry Favorites for Intune and Autopilot Settings"
        Author      = "MrWyss-MSFT"
        Elevation   = $false
    }
)

#region Split-LongString 
function Split-LongString {
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$String,
        [Parameter(Mandatory = $true)]
        [int]$ChunkSize
    )
    $regex = "(.{1,$ChunkSize})(?:\s|$)"
    $splitStrings = [regex]::Matches($string, $regex) | ForEach-Object { $_.Groups[1].Value }
    $splitStrings
}
#endregion

#region New-ConsoleMenu
Function New-ConsoleMenu {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]$Title,
        [Parameter(Mandatory = $true)]
        [array]$Options,
        [Parameter(Mandatory = $false)]
        [int]$MaxStringLength = 0,
        [Parameter(Mandatory = $false)]
        [string[]]$ExcludeProperties,
        [Parameter(Mandatory = $false)]
        [switch]$AddDevideLines,
        [Parameter(Mandatory = $false)]
        [switch]$StopIfWrongWidth
    )


    # exclude properties from output if they are in the $ExcludeProperties array and store the result in $selectedProperties
    if ($ExcludeProperties) {
        [array]$selectedProperties = $Options[0].Keys | ForEach-Object {
            if ($ExcludeProperties -notcontains $_) {
                $_
            }
        }
    }
    else {
        # Nothing to exclude
        [array]$selectedProperties = $Options[0].Keys
    }

    # Calculate the maximum length of each value and key in case the key is longer than the value
    $lengths = @{}
    foreach ($item in $Options) {
        foreach ($property in $item.Keys) {
            if ($selectedProperties -icontains $property) {
                $valueLength = $item[$property].ToString().Length
                $keyLength = $property.ToString().Length
                # if key name is longer than value, use key length as value length
                if ($keyLength -gt $valueLength) {
                    $valueLength = $keyLength
                }
                if ($lengths.ContainsKey($property)) {
                    if ($valueLength -gt $lengths[$property]) {
                        $lengths[$property] = $valueLength
                    }
                }
                else {
                    $lengths.Add($property, $valueLength)
                }
            }
        }
    }

    # if $MaxStringLength is set, we need to limit the maximum length of each string in $lengths
    if ($MaxStringLength -gt 0) {
        foreach ($property in $selectedProperties) {
            if ($lengths[$property] -gt $MaxStringLength) {
                $lengths[$property] = $MaxStringLength
            }
        }
    }

    # Calculcate the maximum width using all selected properties
    $maxWidth = ($lengths.Values | Measure-Object -Sum).Sum

    # Add some extra space for each added table character
    # for the outer characters plus a space
    $maxWidth = $maxWidth + 3 
    # 1 + for the "Nr" header and one for each selected property times three because of two spaces and one extra character
    $maxWidth = $maxWidth + (1 + $selectedProperties.count) * 3 

    # create the menu with the $consoleMenu array
    $consoleMenu = @()
    $consoleMenu += "$([char]0x2554)" + "$([Char]0x2550)" * $maxWidth + "$([char]0x2557)"

    foreach ($titlePart in ($Title -split "\r?\n")) {
        $consoleMenu += "$([Char]0x2551)" + " " * [Math]::Floor(($maxWidth - ($titlePart.Length + 2)) / 2) + $titlePart + " " * [Math]::Ceiling(($maxWidth - ($titlePart.Length + 2)) / 2 + 2) + "$([Char]0x2551)"    
    }
    $consoleMenu += "$([Char]0x2560)" + "$([Char]0x2550)" * $maxWidth + "$([Char]0x2563)"
    # now add the header using just the properties from $selectedProperties
    $header = "$([Char]0x2551)" + " Nr" + " " * (3) + "$([Char]0x2551)"

    foreach ($property in $selectedProperties) {
        $header += " " + $property + " " * ($lengths[$property] - ($property.Length - 1)) + "$([Char]0x2551)"
    }
    $consoleMenu += $header
    $consoleMenu += "$([Char]0x2560)" + "$([Char]0x2550)" * $maxWidth + "$([Char]0x2563)"
    # now add the items
    $i = 0
    foreach ($item in $Options) {
        $i++
        $line = "$([Char]0x2551)" + " " + "$i" + " " * (5 - $i.ToString().Length) + "$([Char]0x2551)"
        $lineEmpty = "$([Char]0x2551)" + "      " + "$([Char]0x2551)"
        $stringAdded = $false
        foreach ($property in $selectedProperties) {
            
            if ($MaxStringLength -gt 0 -and ($item.$property).Length -gt $MaxStringLength) {
                [array]$strList = Split-LongString -String $item.$property -ChunkSize $MaxStringLength
                $rowCounter = 0              
                foreach ($string in $strList) {
                    # we need a complete new row for the next string, so we close this one and add it to the $consoleMenu array
                    if ($rowCounter -eq 0) {
                        $line += " " + ($string.ToString()) + " " * ($lengths.$property - (($string.ToString()).Length - 1)) + "$([Char]0x2551)"
                        $consoleMenu += $line
                        $stringAdded = $true
                    }
                    else {
                        # This is a new row with nothing bu the remaining string
                        $lineEmpty += " " + ($string.ToString()) + " " * ($lengths.$property - (($string.ToString()).Length - 1)) + "$([Char]0x2551)"
                        $consoleMenu += $lineEmpty
                        $stringAdded = $true
                    }
                    $rowCounter++
                }

                # We can add some devide lines if we want
                if ($AddDevideLines) {
                    if ($i -lt $Options.Count) {
                        $consoleMenu += "$([Char]0x255F)" + "$([char]0x2500)" * $maxWidth + "$([Char]0x2562)"
                    }
                }

            }
            else {
                $line += " " + ($item.$property.ToString()) + " " * ($lengths.$property - (($item.$property.ToString()).Length - 1)) + "$([Char]0x2551)"
                $lineEmpty += "  " + " " * ($lengths.$property) + "$([Char]0x2551)"
                #$consoleMenu += $line
            }
        }

        # if the string was not added, we add it here this is typically the case if the string is not longer than $MaxStringLength
        if (-not $stringAdded) {
            $consoleMenu += $line

            if ($AddDevideLines) {
                if ($i -lt $Options.Count) {
                    $consoleMenu += "$([Char]0x255F)" + "$([char]0x2500)" * $maxWidth + "$([Char]0x2562)"
                }
            }
        }
    }
    $consoleMenu += "$([char]0x255a)" + "$([Char]0x2550)" * $maxWidth + "$([char]0x255D)"
    $consoleMenu += " "
  
    # test if the console window is wide enough to display the menu
    if (($Host.UI.RawUI.WindowSize.Width -lt $maxWidth) -or ($Host.UI.RawUI.BufferSize.Width -lt $maxWidth)) {
        if ($StopIfWrongWidth) {
            Write-Warning "Change your console window size to at least $maxWidth characters width and re-run the script"
            Write-Warning "Or exclude some properties via '-ExcludeProperties' parameter of 'New-ConsoleMenu' cmdlet in the script"    
            break
        }
        else {
            $consoleMenu
            Write-Warning "Change your console window size to at least $maxWidth characters width and re-run the script"
            Write-Warning "Or exclude some properties via '-ExcludeProperties' parameter of 'New-ConsoleMenu' cmdlet in the script"
        }
    }
    else {
        $consoleMenu
    }
}
#endregion


Function Invoke-Gist {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$ScriptObject,
        [switch]$NoConfirm
    )
    Write-Host "You selected:" -ForegroundColor Green
    Write-Host "  Gist Name: $($ScriptObject.Name)" -ForegroundColor Green
    Write-Host "  Description: $($ScriptObject.Description)" -ForegroundColor Green
    Write-Host "  Author: $($ScriptObject.Author)" -ForegroundColor DarkMagenta 
    Write-Host "  Elevation Required: $($ScriptObject.Elevation)" -ForegroundColor $(if ($($ScriptObject.Elevation)) { 'Red' } else { 'Green' })
    Write-Host "  URL: $($ScriptObject.Url)" -ForegroundColor Blue

    If ($NoConfirm) {
        $confirmRun = 0
    }
    else {
        $confirmRun = $Host.UI.PromptForChoice('Run the Script', 'Are you sure you want to proceed?', @('&Yes'; '&No'), 0)
    }
    if ($confirmRun -eq 0) {
        try {
            $wc = New-Object System.Net.WebClient
            $wc.Encoding = [System.Text.Encoding]::UTF8
            Invoke-Expression ($wc.DownloadString($($ScriptObject.Url)))
        }
        catch {
            Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

#if ("iwr gist.ittips.ch/dev/5 | iex" -match 'gist\.ittips\.ch/(?:test/|dev/)?(\d+)') {
if ($($MyInvocation.MyCommand) -match 'gist\.ittips\.ch/(?:test/|dev/)?(\d+)') {
    [int]$paramScriptNumber = $($matches[1])
    Invoke-Gist -ScriptObject $GistCatalog[$paramScriptNumber - 1] -NoConfirm
}
else {
    $selection = -1
    $cleared = $false

    do {
        New-ConsoleMenu -Title $Title -Options $GistCatalog -ExcludeProperties 'Url'
    
        if ($cleared) {
            Write-Host "`"$($selection)`" is invalid. Use any of the shown numbers or type `"Q`" to quit" -ForegroundColor Yellow
        }

        $selection = Read-Host 'Please type the number of the script you want to run or type "Q" to quit'
        #$selection = 'Q'
        # test if the selection is q to quit
        if ($selection -imatch 'q') {
            break
        }

        # test if the selection is a number
        # test if selection is between 1 and the number of options
        if ($selection -match '^\d+$' -and $selection -ge 1 -and $selection -le $GistCatalog.Count) {
            Clear-Host
            Invoke-Gist -ScriptObject $GistCatalog[$selection - 1]

        } 
        else {
            Clear-Host
            $cleared = $true
        }
    
    }
    until ($selection -match '^\d+$' -and $selection -ge 1 -and $selection -le $GistCatalog.Count)
}