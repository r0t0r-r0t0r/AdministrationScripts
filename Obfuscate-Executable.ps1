<#
.SYNOPSIS
Выполняет обфускацию заданного проекта
.PARAMETER Path
Папка с двоичными файлами проекта, который нужно обфусцировать
.PARAMETER Executable
Исполняемый файл, который требуется обфусцировать
.PARAMETER Libraries
Библиотеки, которые нужно обфусцировать дополнительно к исполняемому файлу.
Можно использовать символы подстановки * и ?
.PARAMETER SnkFile
Файл пары ключей для подписи сборок после обфускации
.PARAMETER ReactorExecutable
Путь до исполняемого файла обфускатора
.EXAMPLE
.\Obfuscate-Executable.ps1 -Path 'C:\ReportingClient' -Executable RoadRegionEditor.exe

Обфусцирует только исполняемый файл RoadRegionEditor.exe, лежащий в папке C:\ReportingClient
.EXAMPLE
.\Obfuscate-Executable.ps1 -Path C:\TechnologicalParametersEditor -Executable TechnologicalParametersEditor.exe -Libraries TechnologicalParameters.*.dll -SnkFile C:\src\Spectrans\Spectrans.snk

Обфусцирует исполняемый файл и библиотеки, имя файла которых начинается с TachnologicalParameters. Для подписи сборок после обфускации используется файл пары ключей (C:\src\Spectrans\Spectrans.snk)
Будут подписаны только те сборки, которые имели сильное имя до обфускации
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$True)]
    [string]$Path,

    [Parameter(Mandatory=$True)]
    [string]$Executable,

    [string[]]$Libraries = @(),

    [string]$SnkFile,

    [string]$ReactorExecutable = 'C:\Program Files (x86)\Eziriz\.NET Reactor\dotNET_Reactor.Console.exe'
)

Write-Verbose "Protection started at $(Get-Date)"

$exe = Join-Path $Path $Executable
$libs = $Libraries | ForEach-Object {Join-Path $Path $_} | Get-ChildItem -File

Write-Verbose 'Executable to obfuscate:'
Write-Verbose $exe

Write-Verbose 'Libraries to obfuscate:'
$libs | ForEach-Object { Write-Verbose $_.FullName }

$targetPart = "-file `"$exe`""

if ($SnkFile)
{
    $snKeyPairPart = "-snkeypair $SnkFile"
}

if ($libs.Count -gt 0)
{
    $satellitePart = "-satellite_assemblies `"$($libs -join '/')`""
}

$settingsPart = '-suppressildasm 0 -obfuscation 0 -necrobit 1 -stringencryption 1 -targetfile "<AssemblyLocation>\<AssemblyFileName>"'

$arguments = "$targetPart $snKeyPairPart $satellitePart $settingsPart"

Write-Verbose 'Resulting command:'
Write-Verbose "`"$ReactorExecutable`" $arguments"

Write-Verbose 'Obfuscation is starting'
$psi = New-Object System.Diagnostics.ProcessStartInfo $ReactorExecutable
$psi.Arguments = $arguments
$proc = [System.Diagnostics.Process]::Start($psi)
$proc.WaitForExit();
Write-Verbose 'Obfuscation complete'

Write-Verbose 'Cleaning up'
Remove-Item -Path (Join-Path $Path *.hash)

Write-Verbose "Protection completed at $(Get-Date)"
