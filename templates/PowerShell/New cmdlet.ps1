---
prefix: cmdlet
scope: powershell
---
<#
.SYNOPSIS
    $1
.DESCRIPTION
    $2
.EXAMPLE
    ./$TM_FILENAME_BASE
.NOTES
    Created on $CURRENT_YEAR-$CURRENT_MONTH-$CURRENT_DATE
#>
[cmdletbinding()]
param(

)
BEGIN {
    Set-StrictMode -Version latest
    $ErrorActionPreference = "stop"
}

PROCESS {
    #region --- Functions ---

    #endregion Functions
    $0
}#PROCESS

END {
    Write-Verbose -Message "$($MyInvocation.MyCommand.Name) Completed"
}#END