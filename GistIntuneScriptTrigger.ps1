#iwr gist.ittips.ch/dev | iex
$Branch = "dev"
$Version = "v0.0.2"
$LatestAddition = "(R) New-IntuneRegistryFavorites"
$ScriptPath = "https://raw.githubusercontent.com/MrWyss-MSFT/gist/$Branch"

$RunCMDs = @(
    @{ Choice = 'Get-Win32Apps&Order'; 
        Value = "$ScriptPath/Scripts/Intune/Get-Win32AppsOrder.ps1"; 
        Help  = "Reads the IntuneManagementExtension.log and returns a ordered list of the Win32Apps" 
    }
    @{ Choice = 'Get-CoMgmt&WL'; 
        Value = "$ScriptPath/Scripts/CoMgmt/Get-CoMgmtWL.ps1"; 
        Help  = "Returns if CoManagement is enabled and how the workloads are configured" 
    }
    @{Choice  = 'Get-&AutopilotAndESPProgress.ps1'; 
        Value = "$ScriptPath/Scripts/Autopilot/Get-AutopilotAndESPProgress.ps1"; 
        Help  = "Tool to view the Autopilot and ESP Progress" 
    }
    @{Choice  = '&Copy-AutoPilotHashToClipboard.ps1'; 
        Value = "$ScriptPath/Scripts/Autopilot/Copy-AutoPilotHashToClipboard.ps1";
        help  = "Copy the Autopilot Hash to the clipboard"
    }
    @{Choice  = 'New-Intune&RegistryFavorites.ps1'; 
        Value = "$ScriptPath/Scripts/Intune/New-IntuneRegistryFavorites.ps1";
        help  = "Create Registry Favorites for Intune and Autopilot Settings"
    } 
    @{ Choice = '&Quit'; 
        Value = "Quit"; 
        Help  = "Come back soon to GIST - Gist Intune Script Trigger a recursive acronym, if you get the gist of it." 
    }
)
$title = "Gist Intune Script Trigger $Version ($Branch) by https://x.com/MrWyss
Latest addition: 
 - $LatestAddition

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
    Write-Host "`nRunning $Exec" -ForegroundColor Yellow
    $wc = New-Object System.Net.WebClient
    $wc.Encoding = [System.Text.Encoding]::UTF8
    Invoke-Expression ($wc.DownloadString($Exec))
}
