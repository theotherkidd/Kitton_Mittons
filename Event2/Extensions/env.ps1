<#

.SYNOPSIS
Collect Environment variables and export them to a cliXML file


.DESCRIPTION

.EXAMPLE

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.0
Created on: 1/27/2014
Last Modified: 1/27/2014


#>

Param 
    (
        [switch]$Register
    )

#region SetVariables
$Name = "Env"
$title = "Environmental Variables"
$format = "List"
#endregion SetVariables

#region CreateData

Get-ChildItem Env: | Select Name,Value

#endregion CreateData














}