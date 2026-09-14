---
layout: post
title: "Fixing Date Taken/Modified on Google Takeout Photos with ExifTool"
date: 2026-09-13
tags: [photos, exiftool, windows, powershell, google-takeout]
---

When you export photos from Google Takeout, each image file is accompanied by a `.json` sidecar file containing metadata - including the original `photoTakenTime` - but the image itself (especially PNGs) often has no embedded date. This means Windows shows the wrong "Date taken" or "Date modified," and files sort incorrectly.

The fix: use **ExifTool** to read the timestamp out of each JSON sidecar and write it into both the image's EXIF data and the filesystem's date fields.

## Why ExifTool

Google's Takeout JSON sidecars contain a `photoTakenTime.timestamp` field (Unix epoch seconds, UTC). ExifTool can read that value directly out of the JSON and write it into the image's `DateTimeOriginal` EXIF tag, as well as set the file's Windows "Date Modified" field to match.

## Steps

### 1. Install ExifTool

Download the Windows executable from [exiftool.org](https://exiftool.org) (the "Windows Executable" zip). Rename `exiftool(-k).exe` to `exiftool.exe` and place it somewhere on your PATH, e.g. `C:\Dev\tools\`.

Alternatively, install via a package manager:

```powershell
winget install oliverbetz.exiftool
# or
choco install exiftool
```

### 2. Keep JSON and photo pairs together

Google Takeout names each sidecar `<imagefilename>.supplemental-metadata.json` (e.g. `IMG_1234.jpg.supplemental-metadata.json` for `IMG_1234.jpg`). Make sure each photo still sits next to its matching sidecar - don't rename files before running ExifTool, since it matches JSON to image by filename.

### 3. Run ExifTool on the folder

In PowerShell, `cd` into the folder and run:

```powershell
exiftool -r -ext jpg -ext jpeg -d %s -tagsfromfile "%d%f.%e.supplemental-metadata.json" "-DateTimeOriginal<PhotoTakenTimeTimestamp" "-FileModifyDate<PhotoTakenTimeTimestamp" -overwrite_original .
```

What each piece does:

- `-tagsfromfile "%d%f.%e.supplemental-metadata.json"` pairs each image with its sidecar. `%d` is the directory, `%f` the filename without extension, `%e` the extension - this is the option that actually understands per-file substitution and can parse a JSON sidecar as its source (a plain `-json=` argument does not do this substitution).
- `-d %s` tells ExifTool that a bare number coming from the source should be interpreted as Unix epoch seconds. This is required - without it, ExifTool tries to read the raw digits as a formatted date string and fails (e.g. a "Month '43' out of range" error).
- `-DateTimeOriginal<PhotoTakenTimeTimestamp` writes the converted timestamp into the image's EXIF date-taken field.
- `-FileModifyDate<PhotoTakenTimeTimestamp` sets the actual filesystem "Date modified" timestamp - this is a real file attribute, not embedded metadata, and gets set directly.
- `-r` recurses into subfolders; `-overwrite_original` writes changes in place without keeping `_original` backup copies.

For PNGs, which don't reliably carry EXIF, use `XMP:DateCreated` instead of `DateTimeOriginal`:

```powershell
exiftool -r -ext png -d %s -tagsfromfile "%d%f.%e.supplemental-metadata.json" "-XMP:DateCreated<PhotoTakenTimeTimestamp" "-FileModifyDate<PhotoTakenTimeTimestamp" -overwrite_original .
```

### 4. Verify a sample

```powershell
exiftool -DateTimeOriginal -FileModifyDate IMG_1234.jpg
```

Compare the output against the `photoTakenTime.timestamp` in the matching `.supplemental-metadata.json` file to confirm it matches. Google's timestamp is UTC epoch seconds; ExifTool converts it to your local system's date/time formatting, so double-check the value looks sane.

### 5. Optional: batch script for large libraries

For thousands of files across many albums, wrap the ExifTool commands above in a PowerShell script that runs both the JPEG/TIFF pass and the PNG pass, with a `-DryRun` mode (writing to `*_TEST.*` copies first instead of overwriting originals) to confirm the dates land correctly before committing. Also worth logging any files where no matching sidecar was found - Google sometimes truncates long filenames when generating the JSON sidecar, which breaks the automatic pairing and needs a manual fix-up.

## Notes

- **PNG limitation**: PNGs don't natively support EXIF the way JPEGs do. The reliable fix for Windows purposes is `FileModifyDate`, since that's the field Explorer's date columns actually reflect for PNGs.
- **Don't use the `#` modifier here**: it's tempting to add `#` to the destination tag (e.g. `-DateTimeOriginal<PhotoTakenTimeTimestamp#`) to force a "raw value" write, but that's the wrong tool for epoch conversion - it skips ExifTool's date parsing entirely and writes the raw digits as if they were already a formatted date, producing invalid results. Use `-d %s` instead.
- **Alternative tool**: [`google-photos-takeout-helper`](https://github.com/TheLastGimbus/GooglePhotosTakeoutHelper) (npm/GitHub) automates this entire JSON to EXIF and filesystem-date process across a full Takeout export, including fixing mismatched filenames. Worth using instead of hand-rolling matching logic for a large library.
