---
layout: post
title: "ExifTool User Guide"
date: 2026-09-14
tags: [photography, metadata, command-line, tools]
---

## Overview

[ExifTool](https://exiftool.org) by Phil Harvey is the standard command-line tool for reading, writing, and editing metadata (EXIF, IPTC, XMP, and more) in image, video, PDF, and audio files. As of this writing, the current production release is **13.55**, with newer point releases (up through 13.59) available as they roll out — check [exiftool.org/history.html](https://exiftool.org/history.html) for the latest before installing.

## Installation

### Windows

1. Download the Windows Executable zip from [exiftool.org](https://exiftool.org).
2. Extract it, and rename `exiftool(-k).exe` to `exiftool.exe`.
3. Move `exiftool.exe` into a folder on your `PATH` (e.g., `C:\Windows` or a dedicated `C:\Tools` folder added to `PATH`).
4. Confirm it works:

   ```
   exiftool -ver
   ```

### macOS

```bash
brew install exiftool
```

Or download the macOS `.pkg` installer from exiftool.org.

### Linux

```bash
# Debian/Ubuntu
sudo apt install libimage-exiftool-perl

# Fedora
sudo dnf install perl-Image-ExifTool
```

To get the latest version directly from source instead of a distro package:

```bash
curl -LO https://exiftool.org/Image-ExifTool-13.55.tar.gz
tar -xzf Image-ExifTool-13.55.tar.gz
cd Image-ExifTool-13.55
perl Makefile.PL
make test
sudo make install
```

## Basic Usage

### Read all metadata from a file

```bash
exiftool photo.jpg
```

### Read specific tags

```bash
exiftool -DateTimeOriginal -Model -LensModel photo.jpg
```

### Read metadata for every file in a directory

```bash
exiftool /path/to/folder
```

Add `-r` to recurse into subfolders:

```bash
exiftool -r /path/to/folder
```

## Output Formatting

| Flag | Description |
|------|-------------|
| `-s` | Short tag names (no descriptions) |
| `-s3` | Values only, no tag names |
| `-j` | Output as JSON |
| `-csv` | Output as CSV (good for batch exports) |
| `-X` | Output as XML |
| `-G` | Show group names (e.g., `EXIF`, `XMP`, `IPTC`) |
| `-a` | Allow duplicate tags |
| `-u` | Show unknown/undefined tags too |

Example — export a folder's metadata to CSV:

```bash
exiftool -csv -r /path/to/folder > metadata.csv
```

Example — get JSON for scripting:

```bash
exiftool -j photo.jpg
```

## Writing and Editing Tags

### Set a single tag

```bash
exiftool -Artist="Preston Powell" photo.jpg
```

### Set multiple tags at once

```bash
exiftool -Artist="Preston Powell" -Copyright="© 2026 Preston Powell" photo.jpg
```

### Copy metadata from one file to another

```bash
exiftool -TagsFromFile source.jpg target.jpg
```

### Remove all metadata

```bash
exiftool -all= photo.jpg
```

### Remove metadata but keep a few tags

```bash
exiftool -all= --DateTimeOriginal --GPS:all photo.jpg
```

### Apply changes to every file in a folder

```bash
exiftool -Artist="Preston Powell" -r /path/to/folder
```

> **Note:** By default, ExifTool keeps a backup of the original file (e.g., `photo.jpg_original`). Add `-overwrite_original` to skip creating backups once you're confident in your command.

```bash
exiftool -overwrite_original -Artist="Preston Powell" photo.jpg
```

## Working with Dates and Times

### View all date/time tags

```bash
exiftool -time:all -a -G0:1 photo.jpg
```

### Shift all dates by a fixed offset (e.g., camera clock was wrong)

```bash
exiftool "-AllDates+=1:0:0 0:15:0" photo.jpg
```

This shifts by 1 hour, 0 minutes for the date and 15 minutes for the time — adjust as needed.

### Set the file's modification date from EXIF DateTimeOriginal

```bash
exiftool "-FileModifyDate<DateTimeOriginal" photo.jpg
```

## Batch Renaming Files by Date Taken

```bash
exiftool "-FileName<DateTimeOriginal" -d "%Y-%m-%d_%H%M%S.%%e" /path/to/folder
```

This renames files like `2026-09-14_143022.jpg` based on when the photo was actually taken.

## GPS and Location Data

### View GPS coordinates

```bash
exiftool -gpslatitude -gpslongitude photo.jpg
```

### Remove GPS data (useful before sharing photos publicly)

```bash
exiftool -gps:all= photo.jpg
```

### Geotag photos from a GPX track log

```bash
exiftool -geotag track.gpx photo.jpg
```

## Common Tag Groups

| Group | Contents |
|-------|----------|
| `EXIF` | Camera settings, date/time, lens info |
| `IPTC` | Captions, keywords, copyright (news/stock photo standard) |
| `XMP` | Adobe's extensible metadata (ratings, keywords, edit history) |
| `GPS` | Location coordinates and altitude |
| `Composite` | Calculated tags derived from multiple sources |
| `File` | Filesystem-level info (size, permissions, dates) |
| `MakerNotes` | Manufacturer-specific proprietary data |

List all tags in a group:

```bash
exiftool -G1 -a -s photo.jpg | grep IPTC
```

## Useful One-Liners

**Find all files missing GPS data:**

```bash
exiftool -if 'not $gpslatitude' -filename -r /path/to/folder
```

**List camera models used across a photo library:**

```bash
exiftool -Model -r -csv /path/to/folder | cut -d, -f1 | sort -u
```

**Extract embedded thumbnail:**

```bash
exiftool -b -ThumbnailImage photo.jpg > thumb.jpg
```

**Compare two files' metadata:**

```bash
exiftool -a -G1 -s file1.jpg file2.jpg
```

**Batch add copyright to an entire folder, recursively, no backups:**

```bash
exiftool -overwrite_original -r -Copyright="© 2026 Preston Powell" /path/to/folder
```

## Config Files

ExifTool supports a `.ExifTool_config` file (placed in your home directory or specified with `-config`) to define custom tags, shortcuts, and print conversions. Useful for repeatable workflows — e.g., a shortcut tag that pulls your most-used fields in one command.

Example shortcut definition:

```perl
%Image::ExifTool::UserDefined::Shortcuts = (
    MyShoot => ['Model', 'LensModel', 'DateTimeOriginal', 'GPSLatitude', 'GPSLongitude'],
);
```

Then run:

```bash
exiftool -MyShoot photo.jpg
```

## Reference

- Official site: [https://exiftool.org](https://exiftool.org)
- Full tag name reference: [https://exiftool.org/TagNames/](https://exiftool.org/TagNames/)
- FAQ: [https://exiftool.org/faq.html](https://exiftool.org/faq.html)
- Version history / changelog: [https://exiftool.org/history.html](https://exiftool.org/history.html)
