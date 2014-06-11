$pscxPackage = [System.IO.Path]::GetTempFileName()

Write-Verbose "Downloading Pscx 3.1"
Invoke-WebRequest -Uri http://pscx.codeplex.com/downloads/get/744915 -OutFile $pscxPackage

Write-Verbose "Installing Pscx 3.1"
Start-Job -ScriptBlock { msiexec /package $pscxPackage /quiet } | Wait-Job

Write-Verbose "Cleaning up temp files"
Remove-Item $pscxPackage
