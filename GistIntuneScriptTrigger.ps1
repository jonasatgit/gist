#iwr gist.ittips.ch/dev | iex
$Branch = "dev"
$Version = "v0.0.3"
$LatestAddition = "(R) New-IntuneRegistryFavorites"

$RunCMDs = @(
    @{ Choice = 'Get-Win32Apps&Order'; 
        Value = "https://gist.githubusercontent.com/MrWyss-MSFT/c52f0a4567cba24e9ac8a38416a05bac/raw/cffeca3256e5c4c31fdd8b1cbaa8b86ced9833f5/Get-Win32AppsOrder.ps1"; 
        Help  = "Reads the IntuneManagementExtension.log and returns a ordered list of the Win32Apps" 
    }
    @{ Choice = 'Get-CoMgmt&WL'; 
        Value = "https://gist.githubusercontent.com/MrWyss-MSFT/228ed9f3dd2b67077790a3bef98442d5/raw/51699848761c0625991ff1374f227f945e8f42cd/Get-CoMgmtWL.ps1"; 
        Help  = "Returns if CoManagement is enabled and how the workloads are configured" 
    }
    @{Choice  = 'Get-&AutopilotAndESPProgress.ps1'; 
        Value = "https://gist.githubusercontent.com/MrWyss-MSFT/d511d655f55762233a1d442c24d584f6/raw/6a508ad8ca7f7f5206365f699b9a8c25a01b2dd5/Get-AutopilotAndESPProgress.ps1"; 
        Help  = "Tool to view the Autopilot and ESP Progress" 
    }
    @{Choice  = '&Copy-AutoPilotHashToClipboard.ps1'; 
        Value = "https://gist.githubusercontent.com/MrWyss/b83733e8378139af6032381359e00803/raw/7f87d17406e7e120be25c6c35fe1fc154233f17e/Copy-AutoPilotHashToClipboard.ps1";
        help  = "Copy the Autopilot Hash to the clipboard"
    }
    @{Choice  = 'New-Intune&RegistryFavorites.ps1'; 
        Value = "https://gist.githubusercontent.com/MrWyss-MSFT/500b2270b0b23b2fdc9ddc78092c355d/raw/9e3237f26674e2b0ad69b585849797fb731da0f2/New-IntuneRegistryFavorites.ps1";
        help  = "Create Registry Favorites for Intune and Autopilot Settings"
    } 
    @{ Choice = '&Quit'; 
        Value = "Quit"; 
        Help  = "Come back soon to GIST - Gist Intune Script Trigger a recursive acronym, if you get the gist of it." 
    }
)


$title = "Gist Intune Script Trigger $Version ($Branch) by https://x.com/MrWyss | Source & Improvements: https://github.com/MrWyss-MSFT/gist

Latest addition: 
 - $LatestAddition

!!####### use at your own risk ########## !!
!! Some scripts may requries admin rights !!
!!####################################### !!

"
$msg = "Which script would you like to run?"
$options = foreach ($Choice in $RunCMDs) {
    New-Object System.Management.Automation.Host.ChoiceDescription $Choice.Choice, $Choice.Help
}

$default = 0  # 0=Yes, 1=No
$response = $Host.UI.PromptForChoice($title, $msg, $options, $default)
$Exec = $RunCMDs[$response].Value

If ($Exec -eq "Quit") {
    Write-Host $RunCMDs[$response].Help
}
Else {
    Write-Host "`nExecuting $Exec" -ForegroundColor Green
    
    $decision = $Host.UI.PromptForChoice('Run the Script', 'Are you sure you want to proceed?', @('&Yes'; '&No'), 0)
    if ($decision -eq 0) {
        try {
            $wc = New-Object System.Net.WebClient
            $wc.Encoding = [System.Text.Encoding]::UTF8
            Invoke-Expression ($wc.DownloadString($Exec))
        }
        catch {
            Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    else {
        Write-Host "You selected No" -ForegroundColor Red
    }
}
