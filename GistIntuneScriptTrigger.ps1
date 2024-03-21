#iwr gist.ittips.ch/dev | iex
$Branch = "dev"
$Version = "v0.0.4"
$LatestAddition = "(R) New-IntuneRegistryFavorites"

$GistCatalog = [ordered]@{
    'Get-Win32AppsOrder.ps1'            = @{
        category           = "Intune"
        url                = "https://gist.githubusercontent.com/MrWyss-MSFT/c52f0a4567cba24e9ac8a38416a05bac/raw/cffeca3256e5c4c31fdd8b1cbaa8b86ced9833f5/Get-Win32AppsOrder.ps1"
        description        = "Reads the IntuneManagementExtension.log and returns a ordered list of the Win32Apps"
        author             = "MrWyss-MSFT"
        requires_eleveated = $false
    }
    'Get-CoMgmtWL.ps1'                  = @{
        category           = "CoMgmt"
        url                = "https://gist.githubusercontent.com/MrWyss-MSFT/228ed9f3dd2b67077790a3bef98442d5/raw/51699848761c0625991ff1374f227f945e8f42cd/Get-CoMgmtWL.ps1"
        description        = "Returns if CoManagement is enabled and how the workloads are configured"
        author             = "MrWyss-MSFT"
        requires_eleveated = $true
    }
    'Get-AutopilotAndESPProgress.ps1'   = @{
        category           = "Autopilot"
        url                = "https://gist.githubusercontent.com/MrWyss-MSFT/d511d655f55762233a1d442c24d584f6/raw/6a508ad8ca7f7f5206365f699b9a8c25a01b2dd5/Get-AutopilotAndESPProgress.ps1"
        description        = "Script to view the Autopilot and ESP Progress"
        author             = "MrWyss-MSFT"
        requires_eleveated = $false
    }
    'Copy-AutoPilotHashToClipboard.ps1' = @{
        category           = "Autopilot"
        url                = "https://gist.githubusercontent.com/MrWyss/b83733e8378139af6032381359e00803/raw/7f87d17406e7e120be25c6c35fe1fc154233f17e/Copy-AutoPilotHashToClipboard.ps1"
        description        = "Copy the Autopilot Hash to the clipboard"
        author             = "MrWyss"
        requires_eleveated = $true
    }
    'New-IntuneRegistryFavorites.ps1'   = @{
        category           = "Intune"
        url                = "https://gist.githubusercontent.com/MrWyss-MSFT/500b2270b0b23b2fdc9ddc78092c355d/raw/9e3237f26674e2b0ad69b585849797fb731da0f2/New-IntuneRegistryFavorites.ps1"
        description        = "Create Registry Favorites for Intune and Autopilot Settings"
        author             = "MrWyss-MSFT"
        requires_eleveated = $true
    }
}

# Thx to jonasatgit
Function New-ConsoleMenu {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]$Title,
        [Parameter(Mandatory = $true)]
        [System.Collections.Specialized.OrderedDictionary]$Options
    )

    $maxNameLengh = $Options.GetEnumerator() | ForEach-Object { $_.Name.Length } | Sort-Object -Descending | Select-Object -First 1
    $maxCategoryLengh = $Options.GetEnumerator() | ForEach-Object { $_.Value.category.Length } | Sort-Object -Descending | Select-Object -First 1
    $maxDescriptionLengh = $Options.GetEnumerator() | ForEach-Object { $_.Value.description.Length } | Sort-Object -Descending | Select-Object -First 1

    $maxwidth = $maxNameLengh + $maxCategoryLengh + $maxDescriptionLengh + 18

    $consoleMenu = @()
    # first menu line
    $consoleMenu += "$([char]0x2554)" + "$([Char]0x2550)" * $maxwidth + "$([char]0x2557)"
    # title
    $consoleMenu += "$([Char]0x2551)" + " " * [Math]::Floor(($maxwidth - $title.Length) / 2) + $Title + " " * [Math]::Ceiling(($maxwidth - $title.Length) / 2) + "$([Char]0x2551)"
    # separator
    $consoleMenu += "$([Char]0x255F)" + "$([char]0x2500)" * $maxwidth + "$([Char]0x2562)"
    # menu titles: Category, Name, Description
    $consoleMenu += "$([Char]0x2551)" + " " + "Nr" + " " * (3) + "$([Char]0x2551)" + " " + "Category" + " " * ($maxCategoryLengh - 5) + "$([Char]0x2551)" + " " * 2 + "Name" + " " * ($maxNameLengh - 3) + "$([Char]0x2551)" + " " + "Description" + " " * ($maxDescriptionLengh - 10) + "$([Char]0x2551)"
    # seperator
    $consoleMenu += "$([Char]0x2560)" + "$([Char]0x2550)" * $maxwidth + "$([Char]0x2563)"
    # menu items
    $i = 0
    foreach ($option in $Options.GetEnumerator()) {
        $i++
        $consoleMenu += "$([Char]0x2551)" + " " + "$i" + " " * (5 - $i.ToString().Length) + "$([Char]0x2551)" + " " + $option.Value.category + " " * (($maxCategoryLengh - $option.Value.category.Length) + 3) + "$([Char]0x2551)" + " " * 2 + $option.Name + " " * (($maxNameLengh - $option.Name.Length) + 1) + "$([Char]0x2551)" + " " + $option.Value.description + " " * (($maxDescriptionLengh - $option.Value.description.Length) + 1) + "$([Char]0x2551)"
    }
    $consoleMenu += "$([char]0x255a)" + "$([Char]0x2550)" * $maxwidth + "$([char]0x255D)"
    $consoleMenu += " "
    $consoleMenu
}


$title = "Gist Intune Script Trigger $Version ($Branch) by https://x.com/MrWyss | Source & Improvements: https://github.com/MrWyss-MSFT/gist"
$moreinfo = @"

Latest addition: 
 - $LatestAddition

Attention: 
 - Some scripts may requries admin rights

"@

Write-host $moreinfo -ForegroundColor Yellow
New-ConsoleMenu -Title $title -Options $GistCatalog
$selection = Read-Host "Select a script by number"
if ($selection -match '^\d+$' -and $selection -ge 1 -and $selection -le $GistCatalog.Count) {
    $scriptTitle = $GistCatalog.Keys[$selection - 1]
    $scriptUri = $GistCatalog[$selection - 1].url
    Write-host "You selected: $scriptTitle" -ForegroundColor Green
    Write-host "URL: $scriptUri" -ForegroundColor Green
    $decision = $Host.UI.PromptForChoice('Run the Script', 'Are you sure you want to proceed?', @('&Yes'; '&No'), 0)
    if ($decision -eq 0) {
        try {
            $wc = New-Object System.Net.WebClient
            $wc.Encoding = [System.Text.Encoding]::UTF8
            Invoke-Expression ($wc.DownloadString($scriptUri))
        }
        catch {
            Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
} 
else {
    Write-Host "Invalid selection"
}

