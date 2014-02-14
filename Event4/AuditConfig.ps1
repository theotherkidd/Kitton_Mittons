﻿<#
AuditDeployment
#>
[cmdletbinding(DefaultParameterSetName="Default")]
Param
(
    # Enter the target computername(s)
    [Parameter(ParameterSetName="Default")]
    [Parameter(ParameterSetName="Report")]
    [Parameter(ParameterSetName="Remediate")]
    [string[]]$computername,
    
    # Path to most recent config.xml files directory
    [Parameter(ParameterSetName="Default")]
    [Parameter(ParameterSetName="Report")]
    [Parameter(ParameterSetName="Remediate")]
    [string]$ConfigPath,

    # Path to audit for install directories, only set if you are using a non standard install root
    [Parameter(ParameterSetName="Default")]
    [Parameter(ParameterSetName="Report")]
    [Parameter(ParameterSetName="Remediate")]
    [string]$InstallPath = "c:\DRSMonitoring\config.xml",

    #
    [Parameter(ParameterSetName="Remediate")]
    [switch]$Remediate,

    #
    [Parameter(ParameterSetName="Default")]
    [Parameter(ParameterSetName="Report")]
    [Parameter(ParameterSetName="Remediate")]
    [switch]$ShowProgress,

    #
    [Parameter(ParameterSetName="Report")]
    [Switch]$Report,

    #
    [Parameter(Mandatory,
    ParameterSetName="Report")]
    [String]$Path
)
#region Opening
Write-Verbose "Load Module"
Try {Import-Module Monitoring}
Catch {Throw "Unable to load Module file, verify that the MOnitoring.psm1 file has been loaded on this computer."}
$InstallPath = $InstallPath.replace(';','$')
Write-Debug "`$installpath: $InstallPath "
#endregion Opening

#region Audit
Write-Verbose "Creating Jobs"
$i=0
foreach ($c in $computername)
  {
    $i++
    Start-Job -Name Test$i -ArgumentList $c,$InstallPath,$Remediate -ScriptBlock {
        Param ($Computer,$installpath,$Remediate)
        Write-Verbose "Update config if required"
        if (-not(Test-Config -Target (Join-Path -ChildPath \\$args -ChildPath $InstallPath)))
          {
            if ($Remediate)
              {
                Test-Config -Target (Join-Path -ChildPath \\$args -ChildPath $InstallPath) -Remediate
              }
          }
        Test-Deployment -ComputerName $args
      }
  }
if ($ShowProgress)
  {
    While ((get-job -Name Test*).State -contains "Running")
      {
        $prog = @{
            Activity = "Running Jobs"
            Status = "$((get-job -Name Test* -State Completed).count) of $((Get-Job -Name Test*).Count) Complete" 
            PercentComplete = (((get-job -Name Test* -State Completed).count / (Get-Job -Name Test*).Count) * 100 )
          }
        Write-Progress @prog
      }
  }
While ((get-job -Name Test*).State -contains "Running")
  {
    Write-Verbose "Waiting on jobs to finish"
    Start-Sleep -Seconds 1
  }
#endregion Audit

#region Report
$html = @"
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Security Audit Report</title>
</head><body>
  $(get-job -Name Test* | receive-job | ConvertTo-Html -Fragment -as List | Out-String )
</body></html>
"@ 
#endregion Report