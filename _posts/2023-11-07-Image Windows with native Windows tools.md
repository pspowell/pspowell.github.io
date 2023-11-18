---
layout: post
title:  "Image Windows with native Windows tools"
date:   2023-11-07 23:21
categories: tech
---
## Image Windows with native Windows tools

While many third-party tools exist to backup your PC, a Windows Image Backup created using the Microsoft tools has several advantages:

1. It's free, and already available on your computer
2. If the system crashes or the hard disk fails, you can completely restore the computer from Windows Recovery Mode
3. The backup itself can be mounted and accessed just like a disk drive, e.g., everything can be accessed in whatever computer the backup is later attached to.

There are many defferent ways to do this, but the result is always the creation of a WindowsImageBackup folder that contains everything needed to restore the computer operating system.

## Create the Windows Image Backup

Microsoft provides many paths to perform the task of creating an image backup

### The Microsoft way

Here are the steps to create a Windows Image Backup using Settings
Recovery in Windows 10:

1. Plug in an external drive large enough to hold your backup.  If buying, search for ["256gb USB SSD"](https://www.amazon.com/s?k=256gb+usb+ssd&crid=2MDAQRDJ1YFE9&sprefix=256gb+usb+ssd%2Caps%2C274&ref=nb_sb_noss_1), then adjust the size as needed.  

>**_NOTE:_** You should use an external hard drive or SSD and not use a "flash" drive for these instructions.  "Flash" drives require a different set of instructions.
2. Click on the \*\*Start\*\* menu, then search for "file history", **File History** should show up as a search result, so click on that.
>**Alternate Method:** Type `<Windows Key> + R, then type SDCLT <Enter>`
3. The program _**Backup and Restore (Windows 7)**_ will load.  Click on _**Create a System Image**_ in the top-left of the window.
4. Select _**On a Hard Drive**_, and pick the external drive that you plugged in.
5. Click on _**Start Backup**_


[WATCH A VIDEO OF THIS (Windows 10 and step sequence is different)](https://youtu.be/ap2Nd3ZtJi0?si=Yt3RXhW--SvZ_LU0)

I've written a few helper tools to automate this and handle exceptions, like using a flash drive.  These tools are available [HERE](https://pspowell.github.io/tech/2023/11/08/Windows-Tech-Helper-files.html)
