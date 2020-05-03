#requires -Modules powershell-yaml
<#
.SYNOPSIS
    Script to generate snippets based on templates
.PARAMETER TemplatesFolder
    Folder containing templates
.PARAMETER SnippetsFolder
    Folder containing snippets (output folder)
#>
[CmdletBinding()]
param (
    [ValidateScript( { Test-Path -Path $_ -PathType Container })]
    [string]
    $TemplatesFolder = (Join-Path $PSScriptRoot "templates"),
    
    [ValidateScript( { Test-Path -Path $_ -PathType Container })]
    $SnippetsFolder = (Join-Path $PSScriptRoot "snippets")
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "stop"
function Get-Snippet {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateScript( { Test-Path -Path $_ -PathType Leaf })]
        $Path
    )
    $content = [System.IO.File]::ReadAllText($Path)
    $snippet = @{}
    try {
        $res = $content -match "(?ms)^---\s*(.*?)\s*---\s*"
        if ($res) {

            $snippet = $Matches.1 | ConvertFrom-Yaml
        }
    }
    catch {
        # Do nothing
    }
    if (-not $snippet.Contains("prefix")) {
        Write-Warning "Template $path does not contain any prefix"
        return
    }

    if (-not $snippet.Contains("name")) {
        $snippet.Add("name", [io.path]::GetFileNameWithoutExtension($Path))
    }
    #remove YAML
    $body = $content -replace "(?ms)^---\s*.*?\s*---\s*", ""
    $body = $body -replace "`t", "\t"
    # Splitting body by lines (cf. https://stackoverflow.com/a/60451002)
    $snippet.Add("body", ($body -split "\r?\n|\r"))
    return $snippet
}

function Enter-Folder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $folder,
        
        [Parameter(Mandatory)]
        $SnippetsFolder
    )
    Write-Verbose "Entering folder $folder"
    
    $relPath = Resolve-Path -Path $folder -Relative
    Write-Verbose "relPath = $relPath"
    # .Substring(2) removes the leading ./
    # By convention, the snippet name is the concatenation of the folders
    $snippetFilename = $relPath.Substring(2) -replace "[/\\]", "-"
    $snippetFilename = Join-Path $SnippetsFolder "$snippetFilename.code-snippets"
    Write-verbose "Writing snippets to $snippetFilename"
    $snippets = @{ }
    Get-ChildItem -Path $folder -File | ForEach-Object {
        Write-Verbose "Getting snippet from $($_.FullName)"
        $snippet = Get-Snippet -Path $_.FullName
        if ($snippet) { 
            $name = $snippet["name"]
            $snippet.Remove("name")
            $snippets.Add($name, $snippet)
        }
    }
    if ($snippets.Count -gt 0) {
        ConvertTo-Json $snippets | Out-File -Encoding UTF8  $snippetFilename
        Write-Host "Creating snippets in $snippetFilename"
    }
    Get-ChildItem -Path $folder -Directory | ForEach-Object {
        Enter-Folder -folder $_.FullName -SnippetsFolder $SnippetsFolder
    }
    
}
$TemplatesFolder = Resolve-Path $TemplatesFolder
Push-Location $TemplatesFolder
try {
    Enter-Folder -folder $TemplatesFolder -SnippetsFolder $SnippetsFolder
}
finally {
    Pop-Location
}