Function Get-ESPProgress () {
    <#
    .SYNOPSIS
    Reads the ESP Phase status from Registry, returns PSCustomObject
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, HelpMessage = 'Choose ESP Phase')]
        [ValidateSet("DevicePreparation", "DeviceSetup", "AccountSetup")]
        [String]
        $Phase
    )

    $RegPath = "HKLM:\SOFTWARE\Microsoft\Provisioning\AutopilotSettings"
    try {
        $val = Get-ItemPropertyValue -Path $RegPath -Name $Phase"Category.Status" -ErrorAction Stop
        $val | ConvertFrom-Json | ForEach-Object {
            $_.psobject.properties | ForEach-Object {
                $StepName = ($_.Name -replace "$Phase.", "") -creplace '.(?=[^a-z])', '$& '
                $CategoryState = ""
                $CategoryText = ""
       
                if ($_.value -isnot [string] ) {
                    $CategoryState = $_.value.subcategoryState
                    $CategoryText = $_.value.subcategoryStatusText
                }
                else {
                    $CategoryState = $_.value
                }
                $Props = [ordered]@{
                    StepName      = $StepName
                    CategoryState = $CategoryState
                    CategoryText  = $CategoryText
                }
                New-Object -TypeName PSObject -Property $Props        
            }
        }
    }
    catch {
        $val = $null
    }
}

Function Get-AutopilotProfile () {
    <#
    .SYNOPSIS
    Reads the Autopilot config json from Registry, returns PSCustomObject
    #>
 
    $RegPath = "HKLM:\software\microsoft\provisioning\AutopilotPolicyCache"
    try {
        $val = Get-ItemPropertyValue -Path $RegPath -Name "PolicyJsonCache" -ErrorAction Stop
        $Ret = New-Object PSObject
        $val | ConvertFrom-Json |  ForEach-Object {
            $_.psobject.properties | ForEach-Object {
                $Ret | add-member Noteproperty "$($_.Name.ToString())" $_.Value
            }
        }
        $Ret
    }
    catch {
        $val = $null
    }
}

[Flags()] enum CloudAssignedOobeConfig {
    SkipCortanaOptIn = 1
    OobeUserNotLocalAdmin = 2
    SkipExpressSettings = 4
    SkipOemRegistration = 8
    SkipEula = 16
    TPMAttestation = 32
    AADDeviceauth = 64
    AADTPMRequired = 128
    SkipWindowsUpgrade = 256
    EnablePatchDownload = 512
    SkipKeyboard = 1024
}
Function Get-CloudAssignedOobeConfig {
    <#
    .SYNOPSIS
    Enumerates the CloudAssignedOobeConfig and returns a yes/no object
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, HelpMessage = 'CloudAssignedOobeConfig Bitmask in decimal')]
        [int]
        $bitmask
    )
    $Ret = New-Object PSObject
    foreach ( $enumValue in [CloudAssignedOobeConfig].GetEnumNames() ) {
       
        $IsIn = $false
        if (($bitmask -band [CloudAssignedOobeConfig]::$enumValue) -eq [CloudAssignedOobeConfig]::$enumValue) {
            $IsIn = $true
        }
        $Ret | add-member Noteproperty $enumValue $IsIn
       
    }
    $Ret
}

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

Function Get-EspSettings() {

    $Ret = New-Object PSObject
    $CurrentEnrollmentId = Get-EnrollmentID
    $path = "HKLM:\SOFTWARE\Microsoft\Enrollments\{0}\FirstSync" -f $CurrentEnrollmentId
   
    $key = "AllowCollectLogsButton"
    [bool][int32]$AllowCollectLogsButton = "0x{0:x}" -f ((Get-ItemProperty -Path $path -Name $key -ErrorAction SilentlyContinue)."$key")
    $Ret | add-member Noteproperty $key $AllowCollectLogsButton

    $key = "ApplicationsDuration"
    $ApplicationsDuration = ((Get-ItemProperty -Path $path -Name $key -ErrorAction SilentlyContinue)."$key")
    $Ret | add-member Noteproperty $key $ApplicationsDuration
   
    $key = "BlockInStatusPage"
    [bool][int32]$BlockInStatusPage = "0x{0:x}" -f ((Get-ItemProperty -Path $path -Name $key -ErrorAction SilentlyContinue)."$key")
    $Ret | add-member Noteproperty $key $BlockInStatusPage

    $key = "CertificatesDuration"
    $CertificatesDuration = ((Get-ItemProperty -Path $path -Name $key -ErrorAction SilentlyContinue)."$key")
    $Ret | add-member Noteproperty $key $CertificatesDuration
   
    $key = "IsServerProvisioningDone"
    [bool][int32]$IsServerProvisioningDone = "0x{0:x}" -f ((Get-ItemProperty -Path $path -Name $key -ErrorAction SilentlyContinue)."$key")
    $Ret | add-member Noteproperty $key $IsServerProvisioningDone

    $key = "IsSyncDone"
    [bool][int32]$IsSyncDone = "0x{0:x}" -f ((Get-ItemProperty -Path $path -Name $key -ErrorAction SilentlyContinue)."$key")
    $Ret | add-member Noteproperty $key $IsSyncDone

    $key = "NetworkingDuration"
    $NetworkingDuration = ((Get-ItemProperty -Path $path -Name $key -ErrorAction SilentlyContinue)."$key")
    $Ret | add-member Noteproperty $key $NetworkingDuration

    $key = "PolicyDuration"
    $PolicyDuration = ((Get-ItemProperty -Path $path -Name $key -ErrorAction SilentlyContinue)."$key")
    $Ret | add-member Noteproperty $key $PolicyDuration

    $key = "ProvisioningStatus"
    [bool][int32]$ProvisioningStatus = "0x{0:x}" -f ((Get-ItemProperty -Path $path -Name $key -ErrorAction SilentlyContinue)."$key")
    $Ret | add-member Noteproperty $key $ProvisioningStatus

    $key = "SkipDeviceStatusPage"
    [bool][int32]$SkipDeviceStatusPage = "0x{0:x}" -f ((Get-ItemProperty -Path $path -Name $key -ErrorAction SilentlyContinue)."$key")
    $Ret | add-member Noteproperty $key $SkipDeviceStatusPage

    $key = "SkipUserStatusPage"
    [bool][int32]$SkipUserStatusPage = "0x{0:x}" -f ((Get-ItemProperty -Path $path -Name $key -ErrorAction SilentlyContinue)."$key")
    $Ret | add-member Noteproperty $key $SkipUserStatusPage

    $key = "SyncFailureTimeout"
    $SyncFailureTimeout = ((Get-ItemProperty -Path $path -Name $key -ErrorAction SilentlyContinue)."$key")
    $Ret | add-member Noteproperty $key $SyncFailureTimeout

    $key = "Timestamp"
    $data = ((Get-ItemProperty -Path $path -Name $key -ErrorAction SilentlyContinue)."$key")
    $Timestamp = [DateTime]::FromFileTime( (((((($data[7] * 256 + $data[6]) * 256 + $data[5]) * 256 + $data[4]) * 256 + $data[3]) * 256 + $data[2]) * 256 + $data[1]) * 256 + $data[0])
    $Ret | add-member Noteproperty $key ((Get-Date $Timestamp).DateTime)
   
   
    $Ret

}
Function Get-Win32AppsFromIMELog () {
    $logfilepath = "$env:Programdata\Microsoft\IntuneManagementExtension\logs\IntuneManagementExtension*.log"
    $MatchPatter = '<!\[LOG\[Get policies = (.*)\]LOG\]!>'
    $lines = Select-String $logfilepath -Pattern $MatchPatter
    #$Apps = @()

    Foreach ($line in $lines) {
        $Policy = $($line.Matches.Groups[1].Value) | ConvertFrom-Json
        if ($null -ne $Policy) {
            Foreach ($App in $Policy) {
                $App.PSObject.Properties.Remove('ExtendedRequirementRules')
                $App.PSObject.Properties.Remove('DetectionRule')
                $App

            }
        }  
    }

}

#Get-Win32AppsFromIMELog

Function Get-TrackedWin32Apps() {
    $path = "HKLM:\SOFTWARE\Microsoft\Windows\Autopilot\EnrollmentStatusTracking\ESPTrackingInfo\Diagnostics\Sidecar\LastLoggedState"
    [int]$AppsCount = 0
    if (Test-Path "$path") {
        $Win32Tracking = Get-ItemProperty $path | Select-Object "./Device/*"
        $Win32LogApps = Get-Win32AppsFromIMELog
        [int]$AppsCount = $Win32Tracking.psobject.properties.Name.count
        Write-host "count: $AppsCount"
        Foreach ($App in $Win32Tracking.psobject.properties) {
            $AppId = ($App.Name -replace "./Device/Vendor/MSFT/EnrollmentStatusTracking/Setup/Apps/Tracking/Sidecar/Win32App_", "").Substring(0, 36)
            $AppStatus = $App.Value
            $AppInfo = $null
            $AppInfo = ($Win32LogApps | Where-Object Id -eq $AppId | Select-Object -first 1)
           
            switch ($AppStatus) {
                1 { $Status = "NotInstalled" }
                2 { $Status = "NotRequired" }
                3 { $Status = "Completed" }
                4 { $Status = "Error" }
                Default { $Status = $AppStatus }
            }
            switch ($AppInfo.Intent) {
                1 { $Intent = "Available" }
                3 { $Intent = "Required" }
                4 { $Intent = "Uninstall" }
                Default { $Intent = $AppInfo.Intent }
            }
            switch ($AppInfo.TargetType) {
                1 { $TargetType = "Number1" }
                2 { $TargetType = "Number2" }
                3 { $TargetType = "Number3" }
                3 { $TargetType = "Number4" }
                Default { $TargetType = $AppInfo.TargetType }
            }
            $AppInfo | Add-Member NoteProperty "InstallStatusEx" $Status
            $AppInfo | Add-Member Noteproperty "IntentExt" $Intent
            $AppInfo | Add-Member NoteProperty "TargetTypeExt" $TargetType
           
            $AppInfo
        }
    }
}

Function Get-TrackedModernApps() {
    param (
        [Parameter()]
        [switch]
        $User
    )

    $BasePath = "SOFTWARE\Microsoft\Windows\Autopilot\EnrollmentStatusTracking\ESPTrackingInfo\Diagnostics\"
    $UserSID = ""
    if ($User.IsPresent) {
        $UserSID = ((Get-ChildItem -Path HKLM:\$BasePath) | Where-Object Name -Like "HKEY_LOCAL_MACHINE\$($BasePath)S-*").PSChildName
        $UserSID = "\$($UserSID)\"

    }
    $path = "HKLM:\{0}{1}ExpectedModernAppPackages" -f $BasePath, $UserSID

    if (Test-Path $path) {
        $Keys = (Get-ChildItem -Path $path | Select-Object -Last 1)
        forEach ($Key in $Keys) {
            forEach ($Value in $Key.GetValueNames()) {
                New-Object PSObject -Property @{
                    Value = switch ($Key.GetValue($Value)) {
                        0 { "not installed" }
                        1 { "installed" }
                        Default { "unknown" }
                    }
                    Name  = $Value -replace "./User/Vendor/MSFT/EnterpriseModernAppManagement/AppManagement/AppStore/", ""
                }
            }
        }
    }
}

Function Get-LastSyncs {
   
    #Returns the Account
    $Accounts = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts
    # Returns the current OMA-DM status (HEX) or error code. 0 = success; else return error code e.g. 0x80072f30
    foreach ($Account in $Accounts) {
        $objSync = New-Object PSObject
        $SyncProfile = Get-ItemProperty -Path "Registry::$($Account.Name)" -Name ServerVer -ErrorAction SilentlyContinue
        If ($SyncProfile.ServerVer -eq '4.0') { $SyncProfileN = "Sync" } Else { $SyncProfileN = "EPMSync" }
        Add-Member -InputObject $objSync -MemberType NoteProperty -Name ProfileName -Value $SyncProfileN
        
        $LastSessionResult = Get-ItemProperty -Path "Registry::$($Account.Name)\Protected\ConnInfo" -Name LastSessionResult
        if ($LastSessionResult.LastSessionResult -eq "0") {
            
            #Write-Host $SyncProfileN "Last Exit Code: SUCCESS"  -ForegroundColor Green 
            $HEX = "{0:x}" -f $LastSessionResult.LastSessionResult
            Add-Member -InputObject $objSync -MemberType NoteProperty -Name LastSessionResult -Value "SUCCESS" 
        }
        else { 
            $HEX = "{0:x}" -f $LastSessionResult.LastSessionResult
            #Write-Host "OMADM Last Exit ERROR Code: 0x"$HEX -ForegroundColor Red 
            Add-Member -InputObject $objSync -MemberType NoteProperty -Name LastSessionResult -Value "$HEX"
        }

        # Returns the last date and time that the device last attempted a OMA-DM sync.
        $AccessTime = Get-ItemProperty -Path "Registry::$($Account.Name)\Protected\ConnInfo" -Name ServerLastAccessTime
        $AccessTime = [Datetime]::ParseExact($AccessTime.ServerLastAccessTime.ToString(), 'yyyyMMdd\THHmmss\Z', $null)
        #Write-Host OMADM Sync Attempt: $AccessTime
        Add-Member -InputObject $objSync -MemberType NoteProperty -Name SyncAttempt -Value $AccessTime

        # Returns the last date and time that the device successfully completed OMA-DM sync.
        $SuccessTime = Get-ItemProperty -Path "Registry::$($Account.Name)\Protected\ConnInfo" -Name ServerLastSuccessTime
        $SuccessTime = [Datetime]::ParseExact($SuccessTime.ServerLastSuccessTime.ToString(), 'yyyyMMdd\THHmmss\Z', $null)
        #Write-Output "Sync Success: $SuccessTime"
        $Time2Sync = NEW-TIMESPAN -Start $AccessTime -End (Get-Date)
        #Write-Host OMADM Sync Success: $SuccessTime "$($Time2Sync.Days)d" "$($Time2Sync.Hours)h" "$($Time2Sync.Minutes)min"
        Add-Member -InputObject $objSync -MemberType NoteProperty -Name SuccessTime -Value $SuccessTime
        Add-Member -InputObject $objSync -MemberType NoteProperty -Name TimeToSync -Value $Time2Sync
        $objSync

    }
}

Write-Host "ESP DevicePreparation" -ForegroundColor Green
Get-ESPProgress -Phase DevicePreparation | Format-Table

Write-Host "ESP DeviceSetup"  -ForegroundColor Green
Get-ESPProgress -Phase DeviceSetup | Format-Table

Write-Host "ESP AccountSetup"  -ForegroundColor Green
Get-ESPProgress -Phase AccountSetup | Format-Table

Write-Host "Autopilot Profile"  -ForegroundColor Green
$AutopilotProfile = Get-AutopilotProfile
$AutopilotProfile | Format-List

Write-Host "Autopilot Profile CloudAssignedOobeConfig"  -ForegroundColor Green
Get-CloudAssignedOobeConfig -bitmask $AutopilotProfile.CloudAssignedOobeConfig | Format-List

Write-Host "EnrollmentID" -ForegroundColor Green
Get-EnrollmentID + 
"`n"

Write-Host "ESP Settings (FirstSync)" -ForegroundColor Green
Get-EspSettings | Format-List

Write-Host "Tracked Win32 Apps (might take a while)"  -ForegroundColor Green
$TrackedWin32Apps = Get-TrackedWin32Apps
$TrackedWin32Apps | Select-Object Name, Id, Version, IntentExt, TargetTypeExt, Targeted, ESPConfiguration, InstallStatusEx, InstallCommandLine, UninstallCommandLine | Format-Table

Write-Host "Modern Apps Device"  -ForegroundColor Green
Get-TrackedModernApps | Format-Table

Write-Host "Modern Apps User"  -ForegroundColor Green
Get-TrackedModernApps -User | Format-Table

Write-Host "Last Syncs"  -ForegroundColor Green
Get-LastSyncs -User | Format-Table

<#todo
Write-Host "Microsoft 365 Apps CSP"  -ForegroundColor Green
Get-TrackedM365App -User | ft

Write-Host "MSI"  -ForegroundColor Green
Get-TrackedMSIApps -User | ft
#>