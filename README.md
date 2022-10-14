# Subatomix.Build.Versioning.Semantic
[![NuGet](https://img.shields.io/nuget/v/Subatomix.Build.Versioning.Semantic.svg)](https://www.nuget.org/packages/Subatomix.Build.Versioning.Semantic)
[![NuGet](https://img.shields.io/nuget/dt/Subatomix.Build.Versioning.Semantic.svg)](https://www.nuget.org/packages/Subatomix.Build.Versioning.Semantic)

Semi-automatic [SemVer2-compatible](https://semver.org/spec/v2.0.0.html)
versioning for .NET and MSBuild.

Features:
- Generates pre-release tags for Git branches, pull requests, and tags.
- Verifies that release tags match their code versions.

## Status

In use by several projects.

## Requirements

This package makes the following assumptions:

- .NET [SDK-style](https://docs.microsoft.com/en-us/dotnet/core/project-sdk/overview)
  project system
- Git source control
- Releases marked with tags like `release/1.2.3-rc.1`\
  (the prefix `release/` followed by a valid
  [SemVer2](https://semver.org/spec/v2.0.0.html) version)

## Usage

Add a reference to this package in your project file or in a
[`Directory.Build.targets`](https://docs.microsoft.com/en-us/visualstudio/msbuild/customize-your-build#directorybuildprops-and-directorybuildtargets)
file.

```xml
<ItemGroup>
  <PackageReference
    Include="Subatomix.Build.Versioning.Semantic"
    Version="1.0.1"
    PrivateAssets="all" />
</ItemGroup>
```

Set the version number in your project file or in a
[`Directory.Build.props`](https://docs.microsoft.com/en-us/visualstudio/msbuild/customize-your-build#directorybuildprops-and-directorybuildtargets)
file.  Use the `VersionPrefix` property only.

```xml
<PropertyGroup>
  <VersionPrefix>1.2.3</VersionPrefix>
</PropertyGroup>
```

Pass the [git refspec](https://git-scm.com/book/en/v2/Git-Internals-The-Refspec)
into the build process using the `Branch` property.

```shell
dotnet build -c Release -p:Branch=refs/heads/mybranch
```

The build will generate a version like `1.2.3-mybranch.20201214.T154854Z` and
set both the `Version` and `VersionSuffix` properties automatically.  To use a
custom build number instead of the default date/time-based one, pass the number
to the build process using the `Counter` property.

```shell
dotnet build -c Release -p:Branch=refs/heads/mybranch -p:Counter=4567
```

The build will generate the version `1.2.3-mybranch.b.4567`.

#### Interaction With Build Servers

To communicate the generated version number to a build server, add one or
more of the following properties to one of your project files.

```xml
<PropertyGroup>
  <SetAzurePipelinesBuildName>true</SetAzurePipelinesBuildName>
  <SetGitHubActionsVersion>true</SetGitHubActionsVersion>
  <SetTeamCityBuildNumber>true</SetTeamCityBuildNumber>
</PropertyGroup>
```

#### Version Stamping

TODO

## Property Reference

#### `Branch`
The full [git refspec](https://git-scm.com/book/en/v2/Git-Internals-The-Refspec)
of the code being built.  The behavior of this package depends primarily on
the format of the refspec:

- `refs/heads/foo`
  - Recognized as a branch named `foo`.
  - Sets the pre-release tag to `foo` followed by a build counter.
- `refs/heads/foo/bar`
  - Recognized as a branch named `foo/bar`.
  - Sets the pre-release tag to `foo-bar` followed by a build counter.
- `refs/pull/42`
  - Recognized as pull request 42.
  - Sets the pre-release tag to `pr.42` followed by a build counter.
- `refs/tag/release/1.2.3-foo.42`
  - Recognized as a pre-release tag named `release/1.2.3-foo.42`.
  - Emits a build error if the `VersionPrefix` property does not match 
    the tag version, `1.2.3`.
  - Sets the pre-release tag to `foo.42` followed by a build counter.
- `refs/tag/release/1.2.3`
  - Recognized as a release tag named `release/1.2.3`.
  - Emits a build error if the `VersionPrefix` property does not match 
    the tag version, `1.2.3`.
  - **Does not** set a pre-release tag or append a build counter.
- `something else entirely`
  - Not recognized.
  - Sets the pre-release tag to `something-else-entirely` followed by a
    build counter.
- empty or not set
  - Sets the pre-release tag to `local`, without a build counter.  This
    default is intended to ease local development.

#### `Counter`
An arbitrary number to distinguish the current build from other builds of
the same refspec.  If not set, the build generates a date/time-based
counter of the form `yyyymmdd.ThhmmssZ` using the current UTC time.

#### `StampOnBuild`
TODO

#### `SetAzurePipelinesBuildName`
When `true`, the build outputs [magic text](https://docs.microsoft.com/en-us/azure/devops/pipelines/scripts/logging-commands?view=azure-devops#updatebuildnumber-override-the-automatically-generated-build-number)
that sets the name and `$(Build.BuildNumber)` [variable](https://docs.microsoft.com/en-us/azure/devops/pipelines/build/variables?view=azure-devops#build-variables-devops-services)
of the current Azure DevOps pipeline run.

#### `SetGitHubActionsVersion`
When `true`, the build outputs [magic text](https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-commands-for-github-actions#setting-an-output-parameter)
that sets the `Version` [output parameter](https://docs.github.com/en/free-pro-team@latest/actions/reference/context-and-expression-syntax-for-github-actions#steps-context)
of the current workflow step.

#### `SetTeamCityBuildNumber`
When `true`, the build outputs [magic text](https://www.jetbrains.com/help/teamcity/service-messages.html#Reporting+Build+Number)
that sets the [build number](https://www.jetbrains.com/help/teamcity/build-number.html)
of the current TeamCity build.

<!--
  Copyright 2022 Subatomix Research Inc.

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
-->
