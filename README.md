# Subatomix.Build.Versioning.Semantic
[![NuGet](https://img.shields.io/nuget/v/Subatomix.Build.Versioning.Semantic.svg)](https://www.nuget.org/packages/Subatomix.Build.Versioning.Semantic)
[![NuGet](https://img.shields.io/nuget/dt/Subatomix.Build.Versioning.Semantic.svg)](https://www.nuget.org/packages/Subatomix.Build.Versioning.Semantic)

Automatic SemVer2 semantic versioning for .NET and MSBuild.

## Status

Nearing production release.

## Usage

This package works with the
[.NET SDK-style](https://docs.microsoft.com/en-us/dotnet/core/project-sdk/overview)
project system.

Add a reference to this package in your project file or in a
[`Directory.Build.targets`](https://docs.microsoft.com/en-us/visualstudio/msbuild/customize-your-build#directorybuildprops-and-directorybuildtargets)
file.

```xml
<ItemGroup>
  <PackageReference
    Include="Subatomix.Build.Versioning.Semantic"
    Version="0.0.0-pre.7"
    PrivateAssets="All" />
</ItemGroup>
```

Set the version number in your project file or in a
[`Directory.Build.props`](https://docs.microsoft.com/en-us/visualstudio/msbuild/customize-your-build#directorybuildprops-and-directorybuildtargets)
file.

```xml
<PropertyGroup>
  <VersionPrefix>1.0.0</VersionPrefix>
</PropertyGroup>
```

To communicate the generated version numbers to a build server, add one or
more of the following properties to one of your project files.

```xml
<PropertyGroup>
  <SetAzurePipelinesBuildName>true</SetAzurePipelinesBuildName>
  <SetGitHubActionsVersion>true</SetGitHubActionsVersion>
  <SetTeamCityBuildNumber>true</SetTeamCityBuildNumber>
</PropertyGroup>
```

More documentation is forthcoming.
