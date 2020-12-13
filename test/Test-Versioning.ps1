<#
    Copyright 2020 Subatomix Research, Inc.

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

    Test SingleTarget "1T Default               " <#none>                             <#none#>    -Expect '^1\.2\.3-local\.\d{8}\.T\d{6}Z$'
    Test SingleTarget "1T Branch                " -Branch refs/heads/foo              <#none#>    -Expect '^1\.2\.3-foo\.\d{8}\.T\d{6}Z$'
    Test SingleTarget "1T Branch                " -Branch refs/heads/foo              <#none#>    -Expect '^1\.2\.3-foo\.\d{8}\.T\d{6}Z$'
    Test SingleTarget "1T Branch + Counter      " -Branch refs/heads/foo              -Counter 42 -Expect '^1\.2\.3-foo\.b\.42$'
    Test SingleTarget "1T Pull Request          " -Branch refs/pull/123/head          <#none#>    -Expect '^1\.2\.3-pr\.123\.\d{8}\.T\d{6}Z$'
    Test SingleTarget "1T Pull Request + Counter" -Branch refs/pull/123/head          -Counter 42 -Expect '^1\.2\.3-pr\.123\.b\.42$'
    Test SingleTarget "1T Pre-Release           " -Branch refs/tags/release/1.2.3-pre <#none#>    -Expect '^1\.2\.3-pre$'
    Test SingleTarget "1T Pre-Release + Counter " -Branch refs/tags/release/1.2.3-pre -Counter 42 -Expect '^1\.2\.3-pre$'
    Test SingleTarget "1T Release               " -Branch refs/tags/release/1.2.3     <#none#>    -Expect '^1\.2\.3$'
    Test SingleTarget "1T Release + Counter     " -Branch refs/tags/release/1.2.3     -Counter 42 -Expect '^1\.2\.3$'
    Test SingleTarget "1T Invalid               " -Branch ?foo?bar?                   <#none#>    -Expect '^1\.2\.3--foo-bar-\.\d{8}\.T\d{6}Z$'
    Test SingleTarget "1T Invalid + Counter     " -Branch ?foo?bar?                   -Counter 42 -Expect '^1\.2\.3--foo-bar-\.b\.42$'
    Test SingleTarget "1T Explicit Suffix       " -Branch refs/heads/foo -Suffix bar  -Counter 42 -Expect '^1\.2\.3-bar$'

    Test MultiTarget  "MT Default               " <#none>                             <#none#>    -Expect '^1\.2\.3-local\.\d{8}\.T\d{6}Z$'
    Test MultiTarget  "MT Branch                " -Branch refs/heads/foo              <#none#>    -Expect '^1\.2\.3-foo\.\d{8}\.T\d{6}Z$'
    Test MultiTarget  "MT Branch                " -Branch refs/heads/foo              <#none#>    -Expect '^1\.2\.3-foo\.\d{8}\.T\d{6}Z$'
    Test MultiTarget  "MT Branch + Counter      " -Branch refs/heads/foo              -Counter 42 -Expect '^1\.2\.3-foo\.b\.42$'
    Test MultiTarget  "MT Pull Request          " -Branch refs/pull/123/head          <#none#>    -Expect '^1\.2\.3-pr\.123\.\d{8}\.T\d{6}Z$'
    Test MultiTarget  "MT Pull Request + Counter" -Branch refs/pull/123/head          -Counter 42 -Expect '^1\.2\.3-pr\.123\.b\.42$'
    Test MultiTarget  "MT Pre-Release           " -Branch refs/tags/release/1.2.3-pre <#none#>    -Expect '^1\.2\.3-pre$'
    Test MultiTarget  "MT Pre-Release + Counter " -Branch refs/tags/release/1.2.3-pre -Counter 42 -Expect '^1\.2\.3-pre$'
    Test MultiTarget  "MT Release               " -Branch refs/tags/release/1.2.3     <#none#>    -Expect '^1\.2\.3$'
    Test MultiTarget  "MT Release + Counter     " -Branch refs/tags/release/1.2.3     -Counter 42 -Expect '^1\.2\.3$'
    Test MultiTarget  "MT Invalid               " -Branch ?foo?bar?                   <#none#>    -Expect '^1\.2\.3--foo-bar-\.\d{8}\.T\d{6}Z$'
    Test MultiTarget  "MT Invalid + Counter     " -Branch ?foo?bar?                   -Counter 42 -Expect '^1\.2\.3--foo-bar-\.b\.42$'
    Test MultiTarget  "MT Explicit Suffix       " -Branch refs/heads/foo -Suffix bar  -Counter 42 -Expect '^1\.2\.3-bar$'
}

function SetUp {
    Write-Host "Restoring dependencies"
    Invoke-DotNetExe restore SingleTarget > $null
    Invoke-DotNetExe restore MultiTarget  > $null
}

function Test {
    param (
        [Parameter(Mandatory, Position=0)] [string] $Project,
        [Parameter(Mandatory, Position=1)] [string] $Name,
        [Parameter()]                      [string] $Branch,
        [Parameter()]                      [int]    $Counter,
        [Parameter()]                      [string] $Suffix,
        [Parameter(Mandatory)]             [regex]  $Expect
    )

    Write-Host "Test: ${Name} ... " -NoNewline

    $Log = Invoke-DotNetExe -Arguments @(
        "build"
        $Project
        "--nologo"
        "--no-restore"
        "--configuration:Release"
        if ($Suffix)  { "--version-suffix:$Suffix" }
        if ($Branch)  { "-p:Branch=$Branch"        }
        if ($Counter) { "-p:Counter=$Counter"      }
    )

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

    $Log = & dotnet.exe $Arguments *>&1 | Out-String

    if ($LASTEXITCODE -ne 0) {
        Write-Warning $Log
        throw "dotnet.exe exited with code $LASTEXITCODE."
    }

    $Log
}

try {
    Push-Location $PSScriptRoot
    Main
}
finally {
    Pop-Location
}
