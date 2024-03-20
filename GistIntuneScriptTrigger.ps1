#iwr gist.ittips.ch/dev | iex
$RunCMDs = @(
    @{ Choice = 'Get-Win32Apps&Order'; 
        Value = "https://gist.githubusercontent.com/MrWyss-MSFT/c52f0a4567cba24e9ac8a38416a05bac/raw"; 
        Help  = "Reads the IntuneManagementExtension.log and returns a ordered list of the Win32Apps" 
    }
    @{ Choice = 'Get-CoMgmt&WL'; 
        Value = "https://gist.githubusercontent.com/MrWyss-MSFT/228ed9f3dd2b67077790a3bef98442d5/raw"; 
        Help  = "Returns if CoManagement is enabled and how the workloads are configured" 
    }
    @{Choice  = 'Get-&AutopilotAndESPProgress.ps1'; 
        Value = "https://gist.githubusercontent.com/MrWyss-MSFT/d511d655f55762233a1d442c24d584f6/raw"; 
        Help  = "Tool to view the Autopilot and ESP Progress" 
    }
    @{Choice  = '&Copy-AutoPilotHashToClipboard.ps1'; 
        Value = "https://gist.githubusercontent.com/MrWyss/b83733e8378139af6032381359e00803/raw";
        help  = "Copy the Autopilot Hash to the clipboard"
    }
    @{Choice  = 'New-Intune&RegistryFavorites.ps1'; 
        Value = "https://gist.githubusercontent.com/MrWyss-MSFT/500b2270b0b23b2fdc9ddc78092c355d/raw";
        help  = "Create Registry Favorites for Intune and Autopilot Settings"
    } 
    @{ Choice = '&Quit'; 
        Value = "Quit"; 
        Help  = "Come back soon to GIST - Gist Intune Script Trigger a recursive acronym, if you get the gist of it." 
    }
)
$title = "Gist Intune Script Trigger v0.0.2 (dev) by https://x.com/MrWyss
Latest addition: 
 - (R) New-IntuneRegistryFavorites

!!####### use at your own risk ########## !!
!! Some scripts may requries admin rights !!
!!####################################### !!

"
$msg = "Which script would you like to run?"
$Choices = foreach ($Choice in $RunCMDs) {
    New-Object System.Management.Automation.Host.ChoiceDescription $Choice.Choice, $Choice.Help
}
$options = $Choices
$default = 0  # 0=Yes, 1=No
$response = $Host.UI.PromptForChoice($title, $msg, $options, $default)
$Exec = $RunCMDs[$response].Value

If ($Exec -eq "Quit") {
    Write-Host $RunCMDs[$response].Help
}
Else {
    Write-Host "Running $Exec"
    $wc = New-Object System.Net.WebClient
    $wc.Encoding = [System.Text.Encoding]::UTF8
    Invoke-Expression ($wc.DownloadString($Exec))
}
