---
layout: post
title: "Power-user WSL setup from scratch"
date: 2026-03-19
tags:
  - wsl
  - windows
  - ubuntu
  - linux
  - development
  - terminal
  - python
  - git
  - productivity
---

If you use Windows but want a serious Linux command-line environment, WSL is the best compromise I know. It gives you fast access to Linux tools without forcing you into a VM, without the friction of dual boot, and without turning your machine into a desktop science project.

This guide is for the setup I actually recommend to power users: a clean Ubuntu-based WSL install with a strong terminal workflow, sane filesystem habits, Git and SSH ready to go, Python tooling, optional Node, and GUI apps used the right way through WSLg.

This is not a guide for forcing a full Linux desktop into WSL. That path is possible, but it is usually brittle and not worth the complexity. WSL shines when you use it as a powerful Linux layer on top of Windows, not as a replacement for Windows itself.

## What this setup is trying to achieve

The goals are simple:

| Goal | Why it matters |
|---|---|
| Fast Linux shell | Real Linux tools without leaving Windows |
| Clean, reproducible base | Easy to rebuild if something gets messy |
| Strong terminal UX | Better navigation, search, history, and editing |
| Good project layout | Fewer permission and performance headaches |
| Python and Git ready | Useful from day one |
| GUI apps only where they make sense | Avoid full desktop instability |
| Minimal environment hacks | Fewer weird breakages later |

## The mindset that keeps WSL clean

The biggest WSL problems usually come from using it like a full Linux machine when it is better understood as a Linux subsystem with first-class tooling support.

A few rules prevent most pain:

- Use **WSL2**, not WSL1.
- Use **Linux filesystems for code and tooling**.
- Use **Windows filesystems for shared documents and downloads**.
- Use **WSLg for individual GUI apps**, not full desktop sessions.
- Do **not** hand-edit `DISPLAY`, `WAYLAND_DISPLAY`, or related graphics variables unless you have a very specific reason.
- Do **not** mix WSLg, XRDP, and desktop-environment session hacks unless you want a debugging hobby.

## Start from a clean install

Open an elevated PowerShell window and install Ubuntu:

    wsl --install -d Ubuntu

If WSL is already installed but you want a fresh distro:

    wsl -l -v
    wsl --unregister Ubuntu
    wsl --install -d Ubuntu

After installation, Ubuntu will ask you to create a username and password. Use your normal non-root account for daily work. Do not live as `root`.

Once you are inside Ubuntu, bring the system up to date:

    sudo apt update
    sudo apt upgrade -y

At this point, you have a clean base. Everything after this is about making it efficient and comfortable.

## Core packages: the first useful layer

Install a practical set of tools:

    sudo apt install -y \
      build-essential \
      git curl wget unzip zip \
      ca-certificates gnupg software-properties-common \
      htop btop tree jq \
      ripgrep fd-find fzf \
      neovim vim tmux \
      python3 \
      zsh \
      x11-apps

Here is why these matter:

| Package | Purpose |
|---|---|
| `build-essential` | Compilers and basic build tools |
| `git` | Version control |
| `curl`, `wget` | Downloading and scripting |
| `htop`, `btop` | System monitoring |
| `tree` | Directory visualization |
| `jq` | JSON parsing |
| `ripgrep` | Fast code and text search |
| `fd-find` | Better file finding |
| `fzf` | Fuzzy finding |
| `neovim` | Terminal editor |
| `tmux` | Persistent terminal sessions |
| `python3` | System Python for the OS and quick one-offs (`uv` handles project Pythons) |
| `zsh` | Alternative shell if you want it |
| `x11-apps` | Basic GUI test tools |

Install `uv`, which handles Python versions, project environments, packages, and CLI tools in one program:

    curl -LsSf https://astral.sh/uv/install.sh | sh

Then restart your shell (or run `source ~/.bashrc`) and check it:

    uv --version

## Create a sane working directory layout

Keep your projects in Linux space, not under `/mnt/c`.

Create a few directories:

    mkdir -p ~/projects
    mkdir -p ~/bin
    mkdir -p ~/.local/bin

A good pattern is:

| Path | Use |
|---|---|
| `~/projects` | Source code, scripts, repos |
| `~/bin` | Personal helper scripts |
| `/mnt/c/Users/<you>/Downloads` | Files coming from Windows |
| `/mnt/c/Users/<you>/Documents` | Shared human documents |
| `~/.config` | App config |
| `~/.ssh` | SSH keys |

Why this matters: projects built on the Linux filesystem are usually faster and less error-prone than projects developed directly on mounted Windows paths.

## Configure WSL itself

Edit `/etc/wsl.conf`:

    sudo nano /etc/wsl.conf

Use:

    [automount]
    options = "metadata"

    [network]
    generateHosts = true
    generateResolvConf = true

    [interop]
    enabled = true
    appendWindowsPath = true

Then shut WSL down from PowerShell so the changes take effect:

    wsl --shutdown

The `metadata` option improves permission handling on mounted Windows drives. It does not make `/mnt/c` the ideal place for builds, but it does make cross-boundary work less awkward.

## Basic shell quality-of-life improvements

Even a few aliases and defaults make the shell much more pleasant.

If you are staying on Bash, add this to `~/.bashrc`:

    alias ll='ls -alF'
    alias la='ls -A'
    alias l='ls -CF'
    alias gs='git status'
    alias gd='git diff'
    alias gl='git log --oneline --graph --decorate'
    alias ..='cd ..'
    alias ...='cd ../..'
    alias grep='grep --color=auto'
    alias cls='clear'

    export EDITOR=nvim
    export VISUAL=nvim

    if command -v fdfind >/dev/null 2>&1; then
      alias fd='fdfind'
    fi

If you want Zsh instead:

    chsh -s /usr/bin/zsh

Then start a new shell. If you want Oh My Zsh, install it with the standard script from the project, but keep the plugin list small. A restrained shell setup is usually better than a flashy one that adds latency and fragility.

A practical plugin set is:

    plugins=(git sudo history)

## Git: make it ready immediately

Set your Git identity:

    git config --global user.name "Your Name"
    git config --global user.email "you@example.com"

Useful defaults:

    git config --global init.defaultBranch main
    git config --global pull.rebase false
    git config --global core.editor nvim
    git config --global color.ui auto

Optional but nice:

    git config --global alias.st status
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.cm commit
    git config --global alias.lg "log --oneline --graph --decorate --all"

If you frequently work across Windows and Linux editors, consider normalizing line endings carefully. For many WSL users, this is a safe default:

    git config --global core.autocrlf input

That preserves LF on commit without trying to “help” too aggressively.

## SSH: get keys in place early

Generate a key:

    ssh-keygen -t ed25519 -C "you@example.com"

Then:

    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
    cat ~/.ssh/id_ed25519.pub

Add that public key to GitHub, GitLab, your server, or wherever else you need it.

A simple `~/.ssh/config` is worth having:

    Host github.com
      HostName github.com
      User git
      IdentityFile ~/.ssh/id_ed25519
      IdentitiesOnly yes

Set safe permissions:

    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/config 2>/dev/null || true
    chmod 600 ~/.ssh/id_ed25519
    chmod 644 ~/.ssh/id_ed25519.pub

## Python: the clean power-user setup

Ubuntu’s system Python is fine, but do not treat it like a global junk drawer. Let `uv` own everything Python: project environments, dependencies, Python versions, and command-line tools. You never need to run `pip`, `venv`, or `pipx` by hand.

Good global CLI installs through `uv tool`:

    uv tool install ruff
    uv tool install black
    uv tool install httpie

Each tool gets its own isolated environment, the way `pipx` would do it. If `uv` warns that `~/.local/bin` is not on your `PATH`, run `uv tool update-shell` and restart the shell.

That gives you a very strong baseline:

| Tool | Why use it |
|---|---|
| `uv` | Fast Python package, environment, and version management |
| `ruff` | Extremely fast linting and formatting support |
| `black` | Consistent formatting |
| `httpie` | Better command-line HTTP client |

Keep them current with:

    uv self update
    uv tool upgrade --all

For project work:

    mkdir -p ~/projects
    cd ~/projects
    uv init demo-python
    cd demo-python
    uv add requests
    uv run main.py

`uv init` creates the project files (`pyproject.toml`, `main.py`, `.python-version`, a Git repo). `uv add` creates `.venv` on first use, installs the package, and records it in `pyproject.toml` and `uv.lock`. `uv run` runs inside that environment, so there is nothing to activate.

A few more commands you will use often:

| Command | What it does |
|---|---|
| `uv add --dev pytest` | Add a development-only dependency |
| `uv remove requests` | Remove a dependency |
| `uv sync` | Rebuild `.venv` from `uv.lock` (after cloning a repo, for example) |
| `uv run pytest` | Run any tool inside the project environment |
| `uv python install 3.12` | Download a specific Python version |
| `uv python pin 3.12` | Make this project use that version |

For a single script, `uv` can store its dependencies in the file itself:

    uv init --script fetch.py
    uv add --script fetch.py requests
    uv run fetch.py

Commit `pyproject.toml`, `uv.lock`, and `.python-version`. Leave `.venv` out (the `.gitignore` that `uv init` writes already does).

The key idea is simple: keep project dependencies inside the project, and keep your global environment boring.

## Node.js: optional, but common

If you work with modern web tooling, install Node with `nvm` rather than Ubuntu packages:

    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

Restart your shell, then:

    nvm install --lts
    node --version
    npm --version

This keeps Node isolated and easy to change later.

## Neovim or Vim: pick one and commit

You do not need a huge editor configuration to be productive. You need one editor you can trust from anywhere.

A minimal `~/.vimrc` or `~/.config/nvim/init.vim` can already carry a lot of weight:

    set number
    set relativenumber
    set expandtab
    set shiftwidth=4
    set tabstop=4
    set smartindent
    set ignorecase
    set smartcase
    set incsearch
    set hlsearch
    set clipboard=unnamedplus

That last line may depend on clipboard integration and environment details, but the rest is a good minimal core.

## tmux: the productivity multiplier

A simple `tmux` setup turns WSL into something much more resilient.

Create `~/.tmux.conf`:

    set -g mouse on
    set -g history-limit 100000
    setw -g mode-keys vi
    set -g default-terminal "screen-256color"

Then start a session:

    tmux new -s main

Now you can split panes, keep long-running processes alive, and recover from terminal accidents without losing your place.

## GUI apps in WSL: use WSLg the right way

On current Windows 11 systems, WSLg is the intended GUI path. That means individual Linux GUI applications can open directly on your Windows desktop.

Install a few useful apps:

    sudo apt install -y \
      xfce4-terminal \
      thunar \
      file-roller \
      mousepad \
      gedit

Then just run them:

    thunar
    xfce4-terminal
    mousepad

This is the sweet spot. You get Linux GUI tools without needing a full desktop environment. Resist the temptation to install a complete desktop session unless you truly need one and are willing to own the complexity.

## What not to do with graphics

There are a few traps that repeatedly waste time:

- Do not set `DISPLAY` manually unless you know exactly why.
- Do not mix old X-server advice with modern WSLg assumptions.
- Do not expect `startxfce4`, `startplasma-x11`, or a full GNOME session to behave like a real Linux login.
- Do not install three competing graphics/session approaches and then wonder which one is breaking things.

The clean WSL approach is: use the shell for most work, and launch GUI apps individually when needed.

## Windows Terminal: make the front end worthy of the back end

WSL becomes dramatically better when paired with Windows Terminal.

Good settings to consider:

| Setting | Why |
|---|---|
| Use a Nerd Font or good monospaced font | Better symbols and readability |
| Set Ubuntu as default profile | Faster launch into useful work |
| Increase scrollback | Better command history review |
| Use acrylic sparingly or not at all | Looks nice, but clarity matters more |
| Enable copy-on-select only if it fits your habits | Prevent accidental copies |

If you use multiple environments, create separate Windows Terminal profiles for different WSL distros or startup directories.

## Interop: make Windows and Linux cooperate

WSL can call Windows programs, and Windows can access Linux files. That can be extremely useful if kept under control.

Examples:

Open the current Linux directory in Explorer:

    explorer.exe .

Open a file in Windows from WSL:

    notepad.exe README.md

Open VS Code in the current directory:

    code .

From Windows, your Linux files are available under the special network path for WSL. That interoperability is powerful, but remember the general rule: build and run Linux projects in Linux space.

## Backup and rebuild philosophy

A strong WSL setup is not one you can never break. It is one you can rebuild without drama.

That means:

- Prefer a small number of meaningful tools.
- Keep dotfiles in Git if you customize heavily.
- Avoid random environment hacks copied from forum posts.
- Document non-obvious changes.
- Be willing to blow away and rebuild the distro if it gets ugly.

In practice, this mindset makes WSL much less stressful.

## A practical bootstrap sequence

If I were rebuilding from scratch, the sequence would look like this:

### 1. Install Ubuntu

    wsl --install -d Ubuntu

### 2. Update packages

    sudo apt update
    sudo apt upgrade -y

### 3. Install core tools

    sudo apt install -y \
      build-essential git curl wget unzip zip \
      htop btop tree jq \
      ripgrep fd-find fzf \
      neovim tmux \
      python3 \
      zsh \
      xfce4-terminal thunar file-roller mousepad

### 4. Configure WSL

    sudo tee /etc/wsl.conf > /dev/null <<'EOF'
    [automount]
    options = "metadata"

    [network]
    generateHosts = true
    generateResolvConf = true

    [interop]
    enabled = true
    appendWindowsPath = true
    EOF

### 5. Set up directories

    mkdir -p ~/projects ~/bin ~/.local/bin

### 6. Set up Git

    git config --global user.name "Your Name"
    git config --global user.email "you@example.com"
    git config --global init.defaultBranch main
    git config --global core.editor nvim
    git config --global core.autocrlf input

### 7. Set up Python with uv

    curl -LsSf https://astral.sh/uv/install.sh | sh
    source ~/.bashrc
    uv tool install ruff
    uv tool install black
    uv tool install httpie

### 8. Shut WSL down from PowerShell

    wsl --shutdown

That sequence gets you to a very capable system quickly without overengineering anything.

## A sample `.bashrc` section worth keeping

Here is a compact shell block that earns its keep:

    alias ll='ls -alF'
    alias la='ls -A'
    alias l='ls -CF'
    alias gs='git status'
    alias gd='git diff'
    alias gl='git log --oneline --graph --decorate'
    alias v='nvim'
    alias ..='cd ..'
    alias ...='cd ../..'

    export EDITOR=nvim
    export VISUAL=nvim

    if command -v fdfind >/dev/null 2>&1; then
      alias fd='fdfind'
    fi

    if command -v dircolors >/dev/null 2>&1; then
      eval "$(dircolors -b)"
      alias ls='ls --color=auto'
    fi

It improves daily usability without turning your shell config into a museum of cleverness.

## Common mistakes that make WSL feel worse than it is

| Mistake | Better approach |
|---|---|
| Doing development in `/mnt/c` | Keep repos in `~/projects` |
| Running as `root` for normal work | Use your regular user and `sudo` when needed |
| Forcing a full desktop environment | Use WSLg for individual apps |
| Hand-editing graphics environment variables | Let WSLg manage them |
| Installing too many overlapping tools | Keep the stack intentional |
| Treating WSL as sacred and unrebuildable | Make it easy to recreate |

## Who this setup is for

This setup is good for:

- developers who live in terminals
- Windows users who want Linux tooling without abandoning Windows
- Python and scripting workflows
- Git-heavy work
- web development with Node as needed
- people who want a durable daily-driver environment

It is not ideal for:

- users who want a full Linux desktop as the primary experience
- heavy GPU-native Linux desktop workflows
- people who want WSL to behave exactly like a bare-metal Linux install

Those are different use cases and deserve different tools.

## Final recommendation

If your goal is a power-user workstation on Windows, the best WSL setup is usually the least theatrical one.

Install Ubuntu. Keep your code in Linux space. Add a strong terminal stack. Use Git and SSH properly. Let `uv` manage Python projects and tools. Launch Linux GUI apps individually through WSLg when they are actually useful. Avoid the urge to turn WSL into an ersatz desktop distro.

That path is stable, fast, and rebuildable. More importantly, it leaves your energy available for real work instead of continuous environment repair.