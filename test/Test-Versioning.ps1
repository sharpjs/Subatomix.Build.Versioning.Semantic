<#
    Copyright (C) 2020 Subatomix Research, Inc.

    Permission to use, copy, modify, and distribute this software for any
    purpose with or without fee is hereby granted, provided that the above
    copyright notice and this permission notice appear in all copies.

    THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
    WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
    MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
    ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
    WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
    ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
    OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#>

#Requires -Version 5.0
$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

function Main {
    SetUp
    Test "Default               " <#none>                             <#none#>    -Expect '^1\.2\.3-local\.\d{8}\.\d{5,6}$'
    Test "Branch                " -Branch refs/heads/foo              <#none#>    -Expect '^1\.2\.3-foo\.\d{8}\.\d{5,6}$'
    Test "Branch + Counter      " -Branch refs/heads/foo              -Counter 42 -Expect '^1\.2\.3-foo\.b\.42$'
    Test "Pull Request          " -Branch refs/pull/123               <#none#>    -Expect '^1\.2\.3-pr\.123\.\d{8}\.\d{5,6}$'
    Test "Pull Request + Counter" -Branch refs/pull/123               -Counter 42 -Expect '^1\.2\.3-pr\.123\.b\.42$'
    Test "Pre-Release           " -Branch refs/tags/release/1.2.3-pre <#none#>    -Expect '^1\.2\.3-pre$'
    Test "Pre-Release + Counter " -Branch refs/tags/release/1.2.3-pre -Counter 42 -Expect '^1\.2\.3-pre$'
    Test "Release               " -Branch refs/tags/release/1.2.3     <#none#>    -Expect '^1\.2\.3$'
    Test "Release + Counter     " -Branch refs/tags/release/1.2.3     -Counter 42 -Expect '^1\.2\.3$'
    Test "Invalid               " -Branch ?foo?bar?                   <#none#>    -Expect '^1\.2\.3--foo-bar-\.\d{8}\.\d{5,6}$'
    Test "Invalid + Counter     " -Branch ?foo?bar?                   -Counter 42 -Expect '^1\.2\.3--foo-bar-\.b\.42$'
    Test "Explicit Suffix       " -Branch refs/heads/foo -Suffix bar  -Counter 42 -Expect '^1\.2\.3-bar$'
}

function SetUp {
    Write-Host "Restoring dependencies"
    Invoke-DotNetExe restore > $null
}

function Test {
    param (
        [Parameter(Mandatory, Position=0)] [string] $Name,
        [Parameter()]                      [string] $Branch,
        [Parameter()]                      [int]    $Counter,
        [Parameter()]                      [string] $Suffix,
        [Parameter(Mandatory)]             [regex]  $Expect
    )

    Write-Host "Test: ${Name} ... " -NoNewline

    $Log `
        = Invoke-DotNetExe -Arguments @(
            "build"
            "--nologo"
            "--no-restore"
            "--configuration:Release"
            if ($Suffix)  { "--version-suffix:$Suffix" }
            if ($Branch)  { "-p:Branch=$Branch"        }
            if ($Counter) { "-p:Counter=$Counter"      }
        ) `
        | Out-String

    $Actual `
        = ([regex] '(?<=##vso\[build\.updatebuildnumber\])\S*').Match($Log) `
        | % Value

    if ($Actual -match $Expect) {
        Write-Host "[OK] " -ForegroundColor Green -NoNewline
        Write-Host $Actual
    } else {
        Write-Host "[FAIL]"              -ForegroundColor Red
        Write-Host "  Actual:   $Actual" -ForegroundColor Red
        Write-Host "  Expected: $Expect" -ForegroundColor Red
    }
}

function Invoke-DotNetExe {
    param (
        [Parameter(Mandatory, ValueFromRemainingArguments)]
        [string[]] $Arguments
    )
    & dotnet.exe $Arguments
    if ($LASTEXITCODE -ne 0) { throw "dotnet.exe exited with an error." }
}

try {
    Push-Location $PSScriptRoot
    Main
}
finally {
    Pop-Location
}
