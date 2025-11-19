
Process:

1. Right-click the file → **Pick Link Source**
2. Go to destination folder
3. Right-click → **Drop As → Symbolic Link**

---

## Example 3: Hard Linking Duplicate Files
If you have two copies of a large file on the same drive:

1. Delete one of them  
2. Right-click the remaining one → **Pick Link Source**
3. Right-click on the folder where the deleted copy lived → **Drop As → Hardlink**

You now have two file entries but only one physical copy on disk.

---

# 4. Advanced Features

## Smart Copy
Copies folders *while preserving* hard links inside them.

Useful for:

- Git repositories  
- WSL distros  
- Virtual machine folders  

## Smart Mirror
Mirrors two folders while maintaining link integrity.  
Similar to robocopy /MIR but NTFS-aware.

## Splice / Unsplice
Allows creating link relationships between existing folders without moving data.

---

# 5. Tips, Quirks, and Troubleshooting

### Symlinks Require Administrator or Developer Mode
Symlink creation normally requires elevation unless you enable:

**Windows Settings → Updates & Security → For Developers → Developer Mode**

### Hard Links Work Only on the Same Volume
NTFS limitation.

### Junctions Are Sometimes Better Than Symlinks
Some apps (e.g., legacy Microsoft software) treat junctions more reliably than symbolic directory links.

### LSE Menu Missing?
Try:
- Restart Explorer  
- Log off / on  
- Re-install the VC++ runtime  
- Reinstall LSE  

---

# 6. Uninstalling Link Shell Extension

Use:

**Control Panel → Programs and Features → Link Shell Extension → Uninstall**

This removes shell menu entries and cleans registry keys.

---

# Conclusion

Link Shell Extension is one of the most powerful and useful tools for file organization on Windows.  
Whether you're optimizing disk space, reorganizing directories, or managing complex development environments, LSE gives you reliable NTFS link tools directly in the right-click menu.

If you'd like, I can also create:

- A **PDF version**
- A **DOCX version**
- A GitHub-Pages-ready post using your preferred filename and formatting
- Screenshots or a diagram of link types

Just tell me what you want next.
