<#
.SYNOPSIS
Выполняет обфускацию заданного проекта
.PARAMETER path
Папка с двоичными файлами проекта, который нужно обфусцировать
.PARAMETER exclude
Список файлов, которые требуется исключить из процесса обфускации. Могут использоваться символы подстановки * и .
.PARAMETER reactorExe
Путь до исполняемого файла обфускатора
.EXAMPLE
.\reactorprotect.ps1 -path 'C:\ReportingClient' -exclude (Get-Content exclude.lst)
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$True)]
    [string]$path,

    [string[]]$exclude = @(),

    [string]$reactorExe = 'C:\Program Files (x86)\Eziriz\.NET Reactor\dotNET_Reactor.exe'
)

Write-Verbose "Protection started at $(Get-Date)"

$libs = Get-ChildItem -Path (Join-Path $path *.dll) -Exclude $exclude -File
$exe = Get-ChildItem -Path (Join-Path $path *.exe) -Exclude $exclude -File

Write-Verbose $exe

if ($exe.Count -ne 1)
{
    throw "Exactly one exe file expected"
}

$targetPart = "-file `"$exe`""
$satellitePart = "-satellite_assemblies `"$($libs -join '/')`""
$settingsPart = '-suppressildasm 0 -obfuscation 0 -necrobit 1 -stringencryption 1 -targetfile "<AssemblyLocation>\<AssemblyFileName>"'

$command = "`"$reactorExe`" $targetPart $satellitePart $settingsPart"
Write-Verbose $command

Invoke-Expression "& $command"

Remove-Item -Path (Join-Path $path *.hash)

Write-Verbose "Protection completed at $(Get-Date)"
