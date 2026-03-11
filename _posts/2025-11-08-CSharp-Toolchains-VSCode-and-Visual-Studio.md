---
layout: post
title: "CSharp Toolchains VSCode and Visual Studio"
date: 2025-11-08
tags:
  - csharp
  - dotnet
  - vscode
  - visual-studio
  - toolchains
---

# C# Toolchains: VSCode and Visual Studio {#csharp-toolchains-vscode-and-visual-studio}

This guide explains how the C# toolchain works with **Visual Studio Code** and **Visual Studio**, how the .NET SDK fits into the picture, and how to configure projects correctly.

Understanding the toolchain helps when debugging build issues, setting up development environments, or maintaining consistent builds across machines.

---

# Overview of the C# Toolchain {#overview-of-the-csharp-toolchain}

Modern C# development relies on several components working together.

Typical components include:

- .NET SDK
- MSBuild
- Roslyn compiler
- project files
- runtime
- IDE/editor tooling

Visual Studio and VS Code simply sit on top of this system.

---

# The .NET SDK {#the-net-sdk}

The **.NET SDK** provides the fundamental command-line tools for building and running applications.

Install it from:

https://dotnet.microsoft.com

Verify installation:

```bash
dotnet --version
```

You should see a version similar to:

```text
9.0.100
```

---

# Core CLI Commands {#core-cli-commands}

Create a project:

```bash
dotnet new console
```

Restore dependencies:

```bash
dotnet restore
```

Build the project:

```bash
dotnet build
```

Run the application:

```bash
dotnet run
```

Publish a release build:

```bash
dotnet publish -c Release
```

---

# The Roslyn Compiler {#the-roslyn-compiler}

The **Roslyn compiler** is the C# compiler used by the .NET SDK.

Key responsibilities:

- compiling source code
- producing assemblies
- performing static analysis
- enabling IDE code intelligence

Roslyn is also what powers features such as:

- IntelliSense
- refactoring
- diagnostics
- code analysis

---

# MSBuild {#msbuild}

**MSBuild** is the build engine used by .NET.

Responsibilities include:

- evaluating project files
- determining build steps
- resolving dependencies
- invoking the compiler
- packaging outputs

When you run:

```bash
dotnet build
```

the SDK is internally invoking MSBuild.

---

# Project Files {#project-files}

C# projects are typically defined using `.csproj` files.

Example:

```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net9.0</TargetFramework>
  </PropertyGroup>

</Project>
```

The project file controls:

- target framework
- build options
- dependencies
- output configuration

---

# global.json {#global-json}

The `global.json` file lets you **pin a specific SDK version** for a repository.

This prevents build inconsistencies when different machines have different SDK versions installed.

Example:

```json
{
  "sdk": {
    "version": "9.0.100"
  }
}
```

Place `global.json` at the **root of the repository**.

The .NET CLI will search upward from the working directory to find it.

---

# Why global.json Matters {#why-global-json-matters}

Without `global.json`, the CLI uses the **latest installed SDK**.

That can cause problems:

- CI builds using a different SDK
- developers using different SDKs
- subtle build or runtime differences

Pinning the SDK version improves reproducibility.

---

# Visual Studio Code Setup {#visual-studio-code-setup}

To use C# in VS Code you typically install the following extensions:

- **C#**
- **C# Dev Kit**
- **.NET Install Tool**

These extensions enable:

- IntelliSense
- debugging
- project management
- code navigation

---

# Typical VS Code Workflow {#typical-vs-code-workflow}

1. Install the .NET SDK.
2. Install the C# extension.
3. Open the project folder.
4. Restore dependencies.
5. Build and run.

Example:

```bash
dotnet restore
dotnet build
dotnet run
```

---

# Visual Studio IDE {#visual-studio-ide}

Visual Studio provides a full integrated environment.

It includes:

- GUI project templates
- designer tools
- advanced debugging
- profiling tools
- built-in package management

Visual Studio internally uses the same:

- MSBuild
- Roslyn
- .NET SDK

as the CLI.

---

# CLI vs IDE {#cli-vs-ide}

| Tool | Purpose |
|-----|--------|
| dotnet CLI | scripting and automation |
| VS Code | lightweight editor |
| Visual Studio | full development IDE |

---

# Build Configuration {#build-configuration}

Typical configurations include:

- Debug
- Release

Example build command:

```bash
dotnet build -c Release
```

---

# Running Tests {#running-tests}

If the project includes tests:

```bash
dotnet test
```

This runs all unit tests using the configured test framework.

---

# Publishing Applications {#publishing-applications}

Publishing produces deployable artifacts.

Example:

```bash
dotnet publish -c Release
```

Outputs are typically placed in:

```text
bin/Release/{framework}/publish
```

---

# Multi-Project Solutions {#multi-project-solutions}

Larger applications often use multiple projects.

Example structure:

```text
src/
  app/
  library/
tests/
  unit-tests/
```

Solutions (`.sln` files) organize these projects.

---

# Solution Files {#solution-files}

Create a solution:

```bash
dotnet new sln
```

Add a project:

```bash
dotnet sln add project.csproj
```

---

# Package Management {#package-management}

Dependencies are usually added via NuGet.

Example:

```bash
dotnet add package Newtonsoft.Json
```

Restore packages:

```bash
dotnet restore
```

---

# Summary {#summary}

The C# development toolchain consists of:

- the .NET SDK
- Roslyn compiler
- MSBuild
- project files
- editors or IDEs

VS Code and Visual Studio simply provide different user interfaces over the same underlying tools.

Understanding these layers helps when:

- debugging builds
- configuring CI systems
- maintaining consistent development environments.