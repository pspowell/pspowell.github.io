---
layout: post
title: ".NET Static Methods for PowerShell Cheat Sheet"
date: 2025-10-31
tags: [PowerShell, .NET, Reference, CheatSheet]
---

# 🧩 PowerShell → .NET Static Method Cheat Sheet

> Common static methods and properties you can call with `[Type]::Member`.

---

## 🧮 `[Math]` — Numeric Operations

| Example | Result | Description |
|----------|---------|-------------|
| `[Math]::Round(3.14159, 2)` | `3.14` | Round to 2 decimals |
| `[Math]::Ceiling(4.1)` | `5` | Round **up** |
| `[Math]::Floor(4.9)` | `4` | Round **down** |
| `[Math]::Pow(2, 10)` | `1024` | Power |
| `[Math]::Sqrt(49)` | `7` | Square root |
| `[Math]::Abs(-8)` | `8` | Absolute value |
| `[Math]::PI` | `3.14159265358979` | Constant |
| `[Math]::E` | `2.71828182845905` | Euler’s number |

---

## 🕓 `[DateTime]` — Date & Time

| Example | Result | Description |
|----------|---------|-------------|
| `[DateTime]::Now` | Local time | Current system time |
| `[DateTime]::UtcNow` | UTC time | Coordinated Universal Time |
| `[DateTime]::Today` | Midnight | Date without time |
| `[DateTime]::Parse("2025-10-31")` | `DateTime` | Parse from text |
| `[DateTime]::IsLeapYear(2024)` | `True` | Leap-year check |
| `[DateTime]::DaysInMonth(2025,2)` | `28` | Days in month |

---

## 📄 `[IO.File]` — File Handling

| Example | Result | Description |
|----------|---------|-------------|
| `[IO.File]::ReadAllText("C:\Temp\log.txt")` | File content | Read text |
| `[IO.File]::WriteAllText("C:\Temp\out.txt","Hello")` | — | Write text |
| `[IO.File]::AppendAllText("C:\Temp\out.txt","More")` | — | Append text |
| `[IO.File]::Exists("C:\Temp\out.txt")` | `True/False` | Check file |
| `[IO.File]::Delete("C:\Temp\out.txt")` | — | Delete file |

---

## 📁 `[IO.Directory]` — Directories

| Example | Result | Description |
|----------|---------|-------------|
| `[IO.Directory]::CreateDirectory("C:\Temp\Test")` | DirectoryInfo | Create folder |
| `[IO.Directory]::Exists("C:\Temp\Test")` | Boolean | Check folder |
| `[IO.Directory]::GetFiles("C:\Temp")` | Array of paths | List files |
| `[IO.Directory]::Delete("C:\Temp\Test",$true)` | — | Delete recursively |

---

## 🌐 `[Environment]` — System Info

| Example | Result | Description |
|----------|---------|-------------|
| `[Environment]::MachineName` | Host name | Computer name |
| `[Environment]::UserName` | Account | Current user |
| `[Environment]::OSVersion` | OS info | Windows version |
| `[Environment]::NewLine` | `\n` | System newline |
| `[Environment]::GetFolderPath("Desktop")` | `C:\Users\<User>\Desktop` | Special folder |

---

## 🔤 `[String]` — String Utilities

| Example | Result | Description |
|----------|---------|-------------|
| `[String]::IsNullOrWhiteSpace("  ")` | `True` | Check blank text |
| `[String]::Join(",",1,2,3)` | `"1,2,3"` | Join values |
| `[String]::Concat("A","B","C")` | `"ABC"` | Concatenate |
| `[String]::Compare("A","a",$true)` | `0` | Case-insensitive compare |
| `[String]::Empty` | `""` | Empty string constant |

---

## 🔢 `[Convert]` — Type Conversions

| Example | Result | Description |
|----------|---------|-------------|
| `[Convert]::ToInt32("42")` | `42` | String → Int |
| `[Convert]::ToString(255,16)` | `"ff"` | Number → Hex |
| `[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("Hi"))` | `"SGk="` | Encode |
| `[Convert]::FromBase64String("SGk=")` | Byte[] | Decode |

---

## 🧩 `[Guid]` — Identifiers

| Example | Result | Description |
|----------|---------|-------------|
| `[Guid]::NewGuid()` | `xxxxxxxx-xxxx-...` | Create new GUID |
| `[Guid]::Empty` | `{00000000-0000-0000-0000-000000000000}` | All-zero GUID |

---

## ⚙️ `[Activator]` — Dynamic Instantiation

| Example | Result | Description |
|----------|---------|-------------|
| `[Activator]::CreateInstance([Type])` | Object | Same as `New-Object` |
| `[Activator]::CreateInstance([datetime],2025,1,1)` | DateTime | Call constructor |

---

## ♻️ `[GC]` — Garbage Collector

| Example | Description |
|----------|-------------|
| `[GC]::Collect()` | Force garbage collection (rarely needed) |

---

## 📚 References

- [.NET Base Class Library Reference](https://learn.microsoft.com/en-us/dotnet/api/?view=netframework-4.8)
- [PowerShell about_Types](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_Types)
- [C# Static Classes and Members](https://learn.microsoft.com/en-us/dotnet/csharp/programming-guide/classes-and-structs/static-classes-and-static-class-members)
