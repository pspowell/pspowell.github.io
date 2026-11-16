---
title: "Installing VS Code for WSL"
date: 2026-11-16 09:45:00 -0500
categories: ["Coding & Automation"]
tags: [vscode, wsl, windows11, jekyll, powershell, automation]
excerpt: "One script installs VS Code on Windows, connects it to Ubuntu on WSL, adds the right extensions on both sides, applies sensible settings, and sets up a Jekyll site with tasks and a new-post snippet."
---

VS Code runs on Windows, but with the **WSL** extension it edits files and runs terminals *inside* Ubuntu, so your Linux tools, permissions and line endings all behave. This guide sets that up, with two downloadable scripts that do the whole thing for you.

It assumes WSL and Ubuntu are already installed. If they aren't, start with [Power-user WSL setup from scratch]({% post_url 2026-03-19-power-user-wsl-setup-from-scratch %}) or [Installing Jekyll on WSL]({% post_url 2025-11-23-installing-jekyll-on-wsl %}).

## What You End Up With

- **VS Code** installed on Windows, on your PATH, with "Open with Code" in Explorer's right-click menu
- **Windows-side extensions:** WSL, PowerShell, Python, Ruff, Code Spell Checker, EditorConfig
- **WSL-side extensions:** YAML, markdownlint, GitHub Actions, Liquid, Git Graph
- **A starter `settings.json`** tuned for Markdown and Jekyll, PowerShell 5.1-safe scripts, and Python with uv
- **For your Jekyll site:** a `.vscode` folder with build tasks, hidden build folders, and a `post` snippet that writes the front matter for you

## Quick Start

**Downloads:**
- [Install-VSCodeWSL.ps1]({{ '/assets/scripts/Install-VSCodeWSL.ps1' | relative_url }}): the Windows side; it also runs the Linux script for you
- [setup-vscode-wsl.sh]({{ '/assets/scripts/setup-vscode-wsl.sh' | relative_url }}): the WSL side, if you only want that part

Open a regular (not admin) PowerShell and run:

```powershell
irm https://pspowell.github.io/assets/scripts/Install-VSCodeWSL.ps1 -OutFile $env:TEMP\Install-VSCodeWSL.ps1
powershell -ExecutionPolicy Bypass -File $env:TEMP\Install-VSCodeWSL.ps1
```

That's it. It takes 2–5 minutes, mostly downloads. When it finishes, open Ubuntu and run:

```bash
cd ~/dev/pspowell.github.io && code .
```

The bottom-left corner of VS Code should read **WSL: Ubuntu**.

### Options

| Option | What it does |
|---|---|
| `-Distro Ubuntu-24.04` | Use a different WSL distro name (`wsl -l` shows yours) |
| `-SiteDir '~/dev/mysite'` | Your Jekyll site's folder inside Linux |
| `-KeepSettings` | Don't touch an existing `settings.json` |
| `-ForceSiteFiles` | Overwrite existing `.vscode` files in the site |
| `-SkipWsl` | Windows side only |

For example:

```powershell
powershell -ExecutionPolicy Bypass -File $env:TEMP\Install-VSCodeWSL.ps1 -KeepSettings -SiteDir '~/dev/mysite'
```

The Linux script has matching options if you run it on its own from Ubuntu:

```bash
curl -fsSL https://pspowell.github.io/assets/scripts/setup-vscode-wsl.sh -o ~/setup-vscode-wsl.sh
bash ~/setup-vscode-wsl.sh                       # extensions + ~/dev/pspowell.github.io/.vscode
bash ~/setup-vscode-wsl.sh --site ~/dev/mysite   # a different site
bash ~/setup-vscode-wsl.sh --no-site             # extensions only
bash ~/setup-vscode-wsl.sh --force               # replace existing .vscode files
```

Both scripts are safe to re-run. They skip what's already done and back up your old settings before replacing them.

## What the Scripts Do, Step by Step

If you'd rather do it by hand, or want to know what you're running, here is the same process.

### 1. Install VS Code on Windows

The script uses `winget` for a per-user install, so no admin rights are needed:

```powershell
winget install --id Microsoft.VisualStudioCode -e --scope user --override "/VERYSILENT /NORESTART /MERGETASKS=!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath"
```

The `MERGETASKS` list adds VS Code to your PATH and Explorer's right-click menu, and skips launching it at the end.

By hand: download from [code.visualstudio.com](https://code.visualstudio.com) and tick **Add to PATH** and the **Open with Code** boxes during setup.

### 2. Windows-side extensions

These run in the Windows half of VS Code:

```powershell
code --install-extension ms-vscode-remote.remote-wsl
code --install-extension ms-vscode.powershell
code --install-extension ms-python.python
code --install-extension charliermarsh.ruff
code --install-extension streetsidesoftware.code-spell-checker
code --install-extension editorconfig.editorconfig
code --update-extensions
```

The `DeprecationWarning: url.parse()` lines `code` prints come from VS Code's own installer and are harmless. The scripts filter them out.

**`--force` doesn't update an installed extension.** To update, use `code --update-extensions`, or click **Update** in the Extensions panel.
{: .notice--info}

### 3. User settings

The script writes `%APPDATA%\Code\User\settings.json`, saving any existing file as `settings.json.bak-<date>`. The highlights:

| Setting | Why |
|---|---|
| `"files.eol": "\n"` | Linux line endings everywhere by default |
| `[markdown]` word wrap, keep trailing spaces | Two trailing spaces are a Markdown line break |
| `markdownlint.config` MD013/MD025/MD033/MD041 off | Allows long lines, inline HTML, and posts that start with front matter |
| `[yaml]` 2-space indent | Matches `_config.yml` and front matter |
| `[powershell]` `utf8bom`, CRLF, highlight non-ASCII | Windows PowerShell 5.1 misreads UTF-8 without a BOM, and an em-dash pasted into a script can break it |
| `[python]` Ruff format on save | Fast, consistent formatting |
| `git.autofetch`, `git.pruneOnFetch` | The Source Control panel stays current |

To change anything later: **Ctrl+Shift+P → Preferences: Open User Settings (JSON)**.

### 4. WSL-side extensions

When VS Code is connected to WSL, extensions that read your files run inside Linux, so these are installed from Ubuntu:

```bash
code --install-extension redhat.vscode-yaml
code --install-extension DavidAnson.vscode-markdownlint
code --install-extension github.vscode-github-actions
code --install-extension sissel.shopify-liquid
code --install-extension mhutchie.git-graph
```

The first `code` command in Ubuntu downloads VS Code's server into `~/.vscode-server`, which takes about a minute. After that, `code` opens instantly.

### 5. Jekyll site workspace files

If your site is cloned (it looks for `_config.yml`), the Linux script adds three files to its `.vscode` folder. Jekyll ignores folders that start with a dot, so nothing here is published.

**`settings.json`** hides `_site`, `.jekyll-cache`, `vendor` and `.bundle` from the file list and search, and treats `.html` files as Liquid templates.

**`tasks.json`** lets you build without typing commands:

| Task | Runs |
|---|---|
| **Jekyll: serve** (default, **Ctrl+Shift+B**) | `bundle exec jekyll serve --livereload` |
| Jekyll: build | `bundle exec jekyll build` |
| Jekyll: build for highserv.com | `JEKYLL_ENV=production bundle exec jekyll build --config _config.yml,_config.highserv.yml` |
| Open site in browser | opens `http://localhost:4000` in Windows |

Run any of them from **Terminal → Run Task…**.

**`jekyll.code-snippets`** adds three snippets for Markdown files:

| Type | You get |
|---|---|
| `post` | Full front matter with today's date and time zone, and a drop-down of the nine site categories |
| `postlink` | A link to another post using `post_url` |
| `notice` | A Minimal Mistakes notice box (info, warning, success…) |

Here is what `post` expands to (Tab moves between the fields):

{% raw %}
```yaml
---
title: "Post Title"
date: 2026-11-16 09:45:00 -05:00
categories: ["Coding & Automation"]
tags: [tag-one, tag-two]
excerpt: "One or two sentences for post lists and search results."
---

Intro paragraph.

## First Section
```
{% endraw %}

To share these files with every copy of the repo, commit them:

```bash
cd ~/dev/pspowell.github.io
git add .vscode && git commit -m "Add VS Code workspace files" && git push
```

## Everyday Use

| To… | Do |
|---|---|
| Open the site | `cd ~/dev/pspowell.github.io && code .` |
| Edit a dotfile | `code ~/.bashrc`, `code ~/.ssh/config` |
| Open a file by name | **Ctrl+P**, type part of the name |
| Open a terminal (in Ubuntu, in the project) | **Ctrl+\`** |
| Serve the site | **Ctrl+Shift+B** |
| Preview Markdown | **Ctrl+Shift+V** (Liquid tags show as plain text, so use the served site for the real view) |
| Commit and push | **Ctrl+Shift+G**, type a message, then **Commit** and **Sync** |
| Start a new post | Create `_posts/YYYY-MM-DD-title.md`, type `post`, press **Tab** |

After editing `~/.bashrc`, run `source ~/.bashrc` in the terminal to load the changes.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `code: command not found` in Ubuntu | Close and reopen the Ubuntu window after installing VS Code. WSL picks up the Windows PATH at startup. |
| Bottom-left says nothing about WSL | You opened the folder from Windows. Close it and run `code .` from Ubuntu instead. |
| `winget not found` | Install **App Installer** from the Microsoft Store, or install VS Code by hand and re-run the script. |
| WSL distro not found | Run `wsl -l` and pass the exact name, e.g. `-Distro Ubuntu-24.04`. |
| Extensions panel shows "Install in WSL: Ubuntu" buttons | That extension is only on the Windows side. Click the button to add it to WSL. |
| Ctrl+Shift+B asks which task to run | Pick **Jekyll: serve**; the `.vscode/tasks.json` file may be missing. Re-run `setup-vscode-wsl.sh`. |
| A PowerShell script shows strange characters | Check that the status bar says **UTF-8 with BOM**. If not, click it and choose **Save with Encoding → UTF-8 with BOM**. |
