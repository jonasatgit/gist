Function Get-EnrollmentID {

    $baseKeyPath = 'HKLM:\SOFTWARE\Microsoft\Enrollments'
    $searchValueName = 'ProviderID'
    $searchValueData = 'MS DM Server'

    # Get all subkeys under the base key
    $subkeys = Get-ChildItem -Path $baseKeyPath -Recurse | Where-Object { $_.PSIsContainer }

    # Iterate through each subkey
    foreach ($subkey in $subkeys) {
        # Check if the subkey has the specified value name and data
        $value = Get-ItemProperty -Path $subkey.PSPath -Name $searchValueName -ErrorAction SilentlyContinue
        if ($null -ne $value -and $value.$searchValueName -eq $searchValueData) {
            Return $subkey.PSChildName
        }
    }
}
$EnrollmentID = Get-EnrollmentID

$Keys = @(
    @{   Name = '📃 Policy Manager'; 
        Value = "Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device"; 
        Help  = "Intune Polcies Location" 
    }
    @{   Name = '⚙️ ESP Settings'; 
        Value = "Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Enrollments\$EnrollmentID\FirstSync"; 
        Help  = "ESP Settings Location" 
    }
    @{   Name = '⚙️ Autopilot Settings'; 
        Value = "Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\AutopilotSettings"; 
        Help  = "Autopilot Settings Location" 
    }
    @{   Name = '🩺 Autopilot Policy Cache'; 
        Value = "Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\AutopilotPolicyCache"; 
        Help  = "Autopilot Policy Cache Location" 
    }
    @{   Name = '✅ ESP Tracking Info'; 
        Value = "Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Autopilot\EnrollmentStatusTracking\ESPTrackingInfo\Diagnostics"; 
        Help  = "ESP Tracking Info Location" 
    }
    @{   Name = '🪟 IME Win32Apps'; 
        Value = "Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\IntuneManagementExtension\Win32Apps"; 
        Help  = "IntuneManagementExtension Win32Apps Location" 
    }
    @{   Name = '🩺 AutoPilot Diagnostic Settings'; 
        Value = "Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\Diagnostics\AutoPilot"; 
        Help  = "AutoPilot Diagnostic Settings Location" 
    }
    @{   Name = '🔍 RebootRequiredURIs'; 
        Value = "Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\SyncML\RebootRequiredURIs"; 
        Help  = "CSPs that require a reboot" 
    }    

)

Write-host "`nSetting up the Registry Favorites, find them in the Registry Editor under Favorites`n" -ForegroundColor Green
New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit" -Name Favorites -Force | out-null
foreach ($Key in $Keys) {
    Write-host "Save Favorite $($Key.Name) with value $($Key.Value)"
    New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit\Favorites" -Name $key.Name -Value $key.Value -PropertyType String -Force | Out-Null
}
Write-host "`nTip: Open multiple instances of the Registry Editor with regedit -m" -ForegroundColor Yellow