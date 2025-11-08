
---
layout: post
title: "C# Toolchains: VS Code and Visual Studio Starter Guide"
date: 2025-11-08
tags: [csharp, dotnet, vscode, visual-studio, windows, macos, linux, setup, gui]
---

> A practical, copy‑pasteable guide to set up **C#/.NET** on **VS Code** and **Visual Studio** for console, web, and GUI apps (WinForms/WPF/MAUI/Avalonia). Written to be cross‑platform where possible, with Windows‑specific notes called out.

## Table of Contents
- [tags: \[csharp, dotnet, vscode, visual-studio, windows, macos, linux, setup, gui\]](#tags-csharp-dotnet-vscode-visual-studio-windows-macos-linux-setup-gui)
- [Table of Contents](#table-of-contents)
- [What you’ll install](#what-youll-install)
- [Install the .NET SDK (all setups)](#install-the-net-sdk-all-setups)
- [Install Git (recommended)](#install-git-recommended)
- [Option A — VS Code stack](#option-a--vs-code-stack)
- [Option B — Visual Studio stack](#option-b--visual-studio-stack)
- [Create and run your first app](#create-and-run-your-first-app)
- [Add tests (xUnit)](#add-tests-xunit)
- [GUI options: WinForms, WPF, MAUI, Avalonia](#gui-options-winforms-wpf-maui-avalonia)
  - [Windows‑only desktop](#windowsonly-desktop)
  - [Cross‑platform desktop \& mobile](#crossplatform-desktop--mobile)
- [Packaging \& publishing](#packaging--publishing)
- [Formatting \& analyzers](#formatting--analyzers)
- [Troubleshooting](#troubleshooting)
- [Cheat sheet](#cheat-sheet)
- [📦 Starter Repository Download](#-starter-repository-download)

---

## What you’ll install

**Common to both stacks**
- **.NET SDK** (includes `csc`, Base Class Libraries, and `dotnet` CLI)
- **MSBuild** (ships with .NET/VS; used via `dotnet build` or Visual Studio)
- **NuGet** (package manager, used via `dotnet add package` or VS GUI)
- **Roslyn** compiler & analyzers
- **Git** (version control)

**VS Code stack (modular)**
- **Visual Studio Code**
- **C# Dev Kit** extension (Microsoft)
- *(Optional)* **GitLens**, **.NET Install Tool**, **REST Client**, **Docker**, **Azure Tools**
- *(Optional for GUI)* **Avalonia for VS Code** (designer & templates)

**Visual Studio stack (batteries included)**
- **Visual Studio Community/Pro/Enterprise** with selected **workloads**
- Built‑in: designers (WinForms/WPF/MAUI), Test Explorer, Profiler, Hot Reload, NuGet UI

---

## Install the .NET SDK (all setups)

Verify if you already have it:
```bash
dotnet --info
dotnet --version
```

If not installed, download the latest **.NET SDK** for your OS (Windows/macOS/Linux). After installation, reopen your terminal and verify again.

**Tip (multiple SDKs):**
```bash
dotnet --list-sdks
dotnet --list-runtimes
```

---

## Install Git (recommended)

- Install **Git** for your OS. During setup on Windows, allow it to add Git to your `PATH`.
- Configure your identity:
```bash
git config --global user.name "Your Name"
git config --global user.email you@example.com
```

---

## Option A — VS Code stack

1) **Install VS Code** (Windows/macOS/Linux).  
2) **Install extensions** (Ctrl/Cmd+Shift+X → search & install):
   - **C# Dev Kit** (Microsoft)
   - **GitLens — Git supercharged** (optional but great)
   - **.NET Install Tool** (optional; helps find SDKs)
   - **Avalonia for VS Code** *(optional if you want cross‑platform GUI)*

3) **Check OmniSharp/Language Server**  
The C# Dev Kit includes the C# language server. Open a C# project and confirm IntelliSense works (peek definition, rename, etc.).

4) **Create a project (examples)**  
```bash
# Console app
dotnet new console -n HelloCSharp
cd HelloCSharp

# Web API
dotnet new webapi -n DemoApi

# xUnit tests
dotnet new xunit -n HelloCSharp.Tests
```

5) **Debugging**  
Open the folder in VS Code → press **F5**. The C# Dev Kit will scaffold `launch.json`/`tasks.json` as needed.

6) **Run & test**  
```bash
dotnet build
dotnet run
dotnet test
```

7) **Recommended settings** (`.editorconfig` at your repo root):
```ini
root = true

[*.cs]
charset = utf-8
end_of_line = lf
insert_final_newline = true
indent_style = space
indent_size = 4
dotnet_diagnostic.IDE0055.severity = warning   # formatting
dotnet_diagnostic.CA* .severity = warning      # code analysis
```

---

## Option B — Visual Studio stack

1) **Install Visual Studio (Windows)**  
During setup, select workloads you need:
- **.NET desktop development** (WinForms/WPF)
- **ASP.NET and web development**
- **.NET Multi‑platform App UI development** (.NET MAUI)
- *(Optional)* **Azure development**, **Data storage and processing**, etc.

2) **Create a project**  
- **File → New → Project** → choose **Console App**, **Class Library**, **WinForms App**, **WPF App**, **ASP.NET Core Web API**, or **.NET MAUI App**.
- Pick target framework (e.g., .NET 8/9) and location.

3) **Run, debug, and test**  
- **F5** to run with debugger, **Ctrl+F5** without.
- **Test Explorer** to run xUnit/NUnit/MSTest.
- **Hot Reload** for supported app types (WPF/WinForms/MAUI/Web).

4) **Package management**  
- **Project → Manage NuGet Packages…** to search/install/update packages.

5) **Designers & Live Visual Tree**  
- **WinForms/WPF** drag‑and‑drop designers.
- **XAML Live Preview** and **Live Visual Tree** for runtime UI inspection.

---

## Create and run your first app

```bash
# 1) Create
dotnet new console -n HelloWorld
cd HelloWorld

# 2) Edit Program.cs (example)
# Console.WriteLine("Hello from .NET!");

# 3) Build & run
dotnet build
dotnet run
```

**VS Code:** open the folder and press **F5**.  
**Visual Studio:** open the `.sln`, set project as Startup Project, press **F5**.

---

## Add tests (xUnit)

```bash
# From the solution root
dotnet new xunit -n HelloWorld.Tests
dotnet sln add HelloWorld.Tests/HelloWorld.Tests.csproj
dotnet add HelloWorld.Tests reference HelloWorld/HelloWorld.csproj
dotnet test
```

Add a sample test to `HelloWorld.Tests/UnitTest1.cs`:
```csharp
using Xunit;

public class UnitTest1
{
    [Fact]
    public void True_is_true() => Assert.True(true);
}
```

---

## GUI options: WinForms, WPF, MAUI, Avalonia

### Windows‑only desktop
- **WinForms** (fast to build, classic controls) — **Visual Studio** has the best designer.
- **WPF** (XAML, MVVM, powerful styling/data binding) — **Visual Studio** with XAML Designer & Hot Reload.

### Cross‑platform desktop & mobile
- **.NET MAUI** (Windows, Android, iOS, macOS) — best supported in **Visual Studio**.
- **Avalonia UI** (Windows/macOS/Linux, experimental mobile) — great in **VS Code** *and* **Visual Studio**.
  - VS Code: install **Avalonia for VS Code** → `dotnet new avalonia.app -n MyApp`
  - Run/debug like any .NET app. Designer supports XAML previews.

**Tip:** If you need **Linux GUI**, Avalonia is the simplest path today.

---

## Packaging & publishing

```bash
# Framework‑dependent (requires target runtime on machine)
dotnet publish -c Release

# Self‑contained (ships the runtime)
dotnet publish -c Release -r win-x64 --self-contained true

# Single‑file executable (Windows example)
dotnet publish -c Release -r win-x64 -p:PublishSingleFile=true
```

**Visual Studio:** **Right‑click project → Publish…** then choose Folder, ClickOnce, MSIX, or Azure.

---

## Formatting & analyzers

- Create `.editorconfig` (see above) for consistent code style.
- Add **Roslyn analyzers** package for stricter rules:
```bash
dotnet add package Microsoft.CodeAnalysis.NetAnalyzers
```
- In Visual Studio: **Analyze → Configure Code Analysis**.

---

## Troubleshooting

- **`dotnet` not found**: reopen terminal or log out/in; ensure SDK is installed and `PATH` updated.
- **VS Code IntelliSense not working**: ensure **C# Dev Kit** is installed; open the **project folder**, not a parent directory; check language server logs.
- **Restore errors**: run `dotnet restore`; check network/proxy; clear NuGet cache `dotnet nuget locals all --clear`.
- **Multiple SDKs**: set global version with `global.json`:
```json
{{
  "sdk": {{ "version": "9.0.100" }}
}}
```
- **Designer missing in VS**: verify **workload** is installed via Visual Studio Installer.
- **MAUI build issues**: ensure **.NET MAUI workload** installed and required platforms enabled.

---

## Cheat sheet

```bash
# New projects
dotnet new list
dotnet new console -n App
dotnet new webapi -n Api
dotnet new wpf -n DesktopWpf
dotnet new winforms -n DesktopWinForms
dotnet new avalonia.app -n CrossDesktop

# Build / Run / Test
dotnet build
dotnet run
dotnet test

# Packages
dotnet add package Newtonsoft.Json
dotnet list package

# Solutions
dotnet new sln -n Demo
dotnet sln add **/*.csproj

# Publish (self-contained single file for Windows x64)
dotnet publish -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true
```

---

## 📦 Starter Repository Download

A minimal working **C#/.NET Hello World + xUnit test** solution compatible with both **VS Code** and **Visual Studio**.

**Download:** [CSharp-HelloWorld-Starter.zip](/assets/CSharp-HelloWorld-Starter.zip)

**To open in VS Code or Visual Studio:**
```bash
unzip CSharp-HelloWorld-Starter.zip
cd CSharp-HelloWorld-Starter
dotnet restore
dotnet build
dotnet run
dotnet test
