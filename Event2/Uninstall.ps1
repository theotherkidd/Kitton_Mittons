<#

.SYNOPSIS

.DESCRIPTION

.EXAMPLE

.NOTES


#>
Param
    (
        [String]$Path = "$env:ProgramFiles\Security Audit",
        [string]$ModulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\SecAudit"
    )
Import-Clixml $path\config.xml | foreach {Unregister-ScheduledJob -Name $_.name }
Remove-Item $Path -Recurse
Remove-Item $ModulePath -Recurse