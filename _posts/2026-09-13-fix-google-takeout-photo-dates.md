---
layout: post
title: "Fixing Date Taken/Modified on Google Takeout Photos with ExifTool"
date: 2026-09-13
tags: [photos, exiftool, windows, powershell, google-takeout]
---

When you export photos from Google Takeout, each image file is accompanied by a `.json` sidecar file containing metadata — including the original `photoTakenTime` — but the image itself (especially PNGs) often has no embedded date. This means Windows shows the wrong "Date taken" or "Date modified," and files sort incorrectly.

The fix: use **ExifTool** to read the timestamp out of each JSON sidecar and write it into both the image's EXIF data and the filesystem's date fields.

## Why ExifTool

Google's Takeout JSON sidecars contain a `photoTakenTime.timestamp` field (Unix epoch, UTC). ExifTool can read that value directly out of the JSON and write it into the image's `DateTimeOriginal` EXIF tag, as well as set the file's Windows "Date Modified" and "Date Created" fields to match.

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

Make sure each photo (e.g. `IMG_1234.png`) still sits next to its matching sidecar (`IMG_1234.png.json` or `IMG_1234.json`, depending on the export). Don't rename files before running ExifTool — it matches JSON to image by filename.

### 3. Run ExifTool on the folder

In PowerShell, `cd` into the folder and run:

```powershell
exiftool "-DateTimeOriginal<PhotoTakenTimeTimestamp" -ext png -r .
```

This reads the `photoTakenTime.timestamp` value out of each matching JSON file and writes it into the image's `DateTimeOriginal` EXIF tag. The `-r` flag recurses into subfolders.

### 4. Sync filesystem timestamps to EXIF

PNG's EXIF support is limited — some viewers and Windows Explorer itself don't reliably read `DateTimeOriginal` from a PNG. So also stamp the actual file timestamps:

```powershell
exiftool "-FileModifyDate<PhotoTakenTimeTimestamp" "-FileCreateDate<PhotoTakenTimeTimestamp" -ext png -r .
```

This is the field Explorer actually sorts and displays by, so this step matters even if the EXIF write in step 3 succeeds.

### 5. Verify a sample

```powershell
exiftool -DateTimeOriginal -FileModifyDate -FileCreateDate IMG_1234.png
```

Compare the output against the timestamp in `IMG_1234.png.json` to confirm it matches. Google's timestamp is UTC epoch seconds — ExifTool converts it, but double-check the timezone looks right for your local time.

### 6. Optional: batch script for large libraries

For thousands of files across many albums, wrap the two ExifTool commands in a PowerShell or Python (`uv`) script that walks each Takeout album folder and runs ExifTool per-folder, logging any files where no matching JSON was found. Google sometimes truncates or numbers filenames oddly (e.g. `IMG_1234(1).json`), which needs a small filename-matching fix-up.

## Notes

- **PNG limitation**: PNGs don't natively support EXIF the way JPEGs do. The reliable fix for Windows purposes is step 4 — setting `FileModifyDate`/`FileCreateDate` directly — since that's what Explorer's date columns actually reflect for PNGs.
- **Alternative tool**: [`google-photos-takeout-helper`](https://github.com/TheLastGimbus/GooglePhotosTakeoutHelper) (npm/GitHub) automates this entire JSON → EXIF + filesystem-date process across a full Takeout export, including fixing mismatched filenames. Worth using instead of hand-rolling matching logic for a large library.
