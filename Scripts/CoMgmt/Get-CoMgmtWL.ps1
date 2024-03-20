<#
  .SYNOPSIS
  Returns the Co-Management Workloads Names
  .DESCRIPTION
  Reads the Co-Management Workloads from the CCM_System WMI Class and returns the 
  Workloads as PSCustomObject if they are enabled or not.
#>

[CmdletBinding()]
Param (

)

[Flags()] enum CoManagementFlag {
    CompliancePolicies = 2
    ResourceAccessPolicies = 4
    DeviceConfiguration = 8
    WindowsUpdatesPolicies = 16
    ClientApps = 64
    OfficeClickToRunApps = 128
    EndpointProtection = 4128
    CoManagementConfigured = 8193
    AllWorkloadsIntune = 2147479807
}

$CCM_System = Get-CimInstance -Namespace "root\ccm\InvAgt" -ClassName "CCM_System"


if ($CCM_System.CoManaged) {
    [CoManagementFlag]$CoManagementFlag = [int]$CCM_System.ComgmtWorkloads

    # loop enum values and compare with ComgmtWorkloads
    ForEach ($Workload in ([CoManagementFlag]::GetNames([CoManagementFlag]))) {
        $WorkloadValue = [CoManagementFlag]::$Workload
        $CurrentWorkload = [PSCustomObject]@{
            Workload = $Workload
            isEnabled = $false
        }
        if ($CoManagementFlag.HasFlag($WorkloadValue)) {
            $CurrentWorkload.isEnabled = $true
        }
        $CurrentWorkload
    }
}