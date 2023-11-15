---
layout: post
title:  "System Image backup options"
date:   2023-11-07 23:21
categories: tech
---

## System Image backup options

It is critically important to take an image backup of the operating
system periodically. An image backup differs from a file backup in that
it images the entire disk instead of just files, and allows the disc to
be recreated should it fail.

There are many ways to do this, but they fall into two catagories:

### Use third party imaging software. 

This option typically requires a separate boot disk or USB in order to restore the system image, and can either be installed or run from the same disk or USB. The best third party options
  include:
  
1. [EaseUS ToDo](https://www.easeus.com/backup-software/tb-free.html)
2. [AOEMI](https://www.aomeitech.com/aomei-backupper.html)
3. [MiniTool Shadowmaker](https://www.minitool.com/backup/system-backup.html?cjdata=MXxOfDB8WXww&cjevent=2a09022b7de811ee833c006c0a82b832&utm_source=cj&utm_content=100357191&utm_term=15564468)
4. [Macrium Reflect](https://www.majorgeeks.com/files/details/macrium_reflect_free_edition.html)
5. [Disk2VHD](https://learn.microsoft.com/en-us/sysinternals/downloads/disk2vhd)

### Use software that is included in the operating system.

This option does not require any extra software and typically can be restored
  using the system troubleshooting menu which is available on windows
  boot.  I've written a seperate blog on this [here](https://pspowell.github.io/tech/2023/11/07/Image-Windows-with-native-Windows-tools.html)
  
### My Recommendation
I'm a fan of two methods in particular however. The first uses commands or scripts that execute native Windows commands to build a backup, and the second uses a prebuilt technician boot USB which includes most of the options above.  I've written a post for each of those methods:

1.  Image Windows with native Windows tools [\[I've written a blog\]](https://pspowell.github.io/tech/2023/11/07/Image-Windows-with-native-Windows-tools.html) [\[and another\]](https://pspowell.github.io/tech/2023/11/08/Windows-Tech-Helper-files.html)
2.  Build and use the Hirens BootPE USB [\[another blog\]](https://pspowell.github.io/tech/2023/11/08/Build-and-use-the-Hirens-BootCD-PE-USB.html)

