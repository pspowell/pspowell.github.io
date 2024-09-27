---
layout: post
title:  "Build and use the Hirens BootCD PE USB"
date:   2023-11-08
categories: tech
---

## Build and use the Hirens BootCD PE USB

### Build the USB

1. Download the [Hirens BootCD PE](https://www.hirensbootcd.org/) BootPE image [link](https://www.hirensbootcd.org/files/HBCD_PE_x64.iso)  
2. Download Rufus to your computer [link]([https://www.hirensbootcd.org/files/ISO2USB.exe](https://rufus.ie/en/)) 
3. Follow the instructions on the [Hiren's BootCD PE website](https://www.hirensbootcd.org/usb-booting/) 

### Enroll Key from Disk

On the newest computers, secure boot may be enabled.  In short, this means that the computer will not boot from the device unless it's been "Enrolled" by adding a **M**achine **O**wner **K**ey (MOK) into a hidden, secure record in your UEFI datastore.

One of the ways Ventoy can work with secure boot now is by adding Ventoy’s key as a trusted key to the Machine Owner Key (MOK) database. To add secure boot support with this method,

#### Instructions

Here's a pictorial step-by-step:

1. Press **Enter** on the Verification failed screen.  
    ![verification-failed-0x1a-security-violation](https://www.technewstoday.com/wp-content/uploads/2023/07/verification-failed-0x1a-security-violation.jpg "How To Enable Secure Boot Support For Ventoy 1")
2. Press **any key** on the Shim UEFI key management screen.  
    ![shim-uefi-key-management](https://www.technewstoday.com/wp-content/uploads/2023/07/shim-uefi-key-management.jpg "How To Enable Secure Boot Support For Ventoy 2")
3. Select **Enroll key from disk** and press Enter.  
    ![enroll-key-from-disk](https://www.technewstoday.com/wp-content/uploads/2023/07/enroll-key-from-disk.jpg "How To Enable Secure Boot Support For Ventoy 3")
4. Select **VTOYEFI** and press Enter.  
    ![vtoyefi-enroll-key](https://www.technewstoday.com/wp-content/uploads/2023/07/vtoyefi-enroll-key.jpg "How To Enable Secure Boot Support For Ventoy 4")
5. Select `ENROLL_THIS_KEY_IN_MOKMANAGER.cer` and press Enter.  
    ![enroll-this-key-in-mokmanager](https://www.technewstoday.com/wp-content/uploads/2023/07/enroll-this-key-in-mokmanager.jpg "How To Enable Secure Boot Support For Ventoy 5")
6. Select **Continue** and press Enter in the Enroll MOK screen.  
    ![continue-to-enroll-mok](https://www.technewstoday.com/wp-content/uploads/2023/07/continue-to-enroll-mok.jpg "How To Enable Secure Boot Support For Ventoy 6")
7. Select **Yes** and press Enter to enroll the keys.  
    ![enroll-mok-keys-confirm](https://www.technewstoday.com/wp-content/uploads/2023/07/enroll-mok-keys-confirm.jpg "How To Enable Secure Boot Support For Ventoy 7")
8. Finally, select **Reboot** and press Enter. You should be able to boot with the Ventoy drive now.  
    ![reboot-mok-management](https://www.technewstoday.com/wp-content/uploads/2023/07/reboot-mok-management.jpg "How To Enable Secure Boot Support For Ventoy 8")

#### Quick step-by-step

|Displayed Screen|Action to perform|
|---|---|
|Error|Click "OK"|
|Shim UEFI Key Management|Press any key to continue|
|Perform MOK management|Click "Enroll key from disk"|
|Select Key|Click "VTOYFI"|
|Select Key (again)|Click "ENROLL_THIS_KEY_IN_MOKMANAGER.cer"|
|[Enroll MOK]|Click "Continue"|
|Enroll the key(s)?|Click "Yes"|
|Perform MOK management|Click "Reboot"|

