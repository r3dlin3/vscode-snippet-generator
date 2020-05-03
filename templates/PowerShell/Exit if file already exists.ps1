---
prefix: file-exist
scope: powershell
---
if (Test-Path $$0 -PathType Leaf) {
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes"
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No"
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    $title = "$$0 already exists"
    $message = "Do you want to overwrite it?"

    $result = $host.ui.PromptForChoice($title, $message, $options, 0)

    if ($result -eq 1) {
        exit
    }
}
