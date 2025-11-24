---
date: 2025-11-23
layout: post
tags:
- jekyll
- wsl
- ruby
- windows11
- tutorial
title: Installing Jekyll on WSL (Best Practices Guide)
---

# Installing Jekyll on WSL (Windows Subsystem for Linux)

This guide explains the cleanest, most stable, and
industry‑best‑practice method for installing **Jekyll** using **WSL2 +
Ubuntu** on Windows 11.

------------------------------------------------------------------------

## 1. Install WSL2 + Ubuntu

Open **PowerShell as Administrator** and run:

``` powershell
wsl --install -d Ubuntu
```

If prompted, restart your computer.

When Ubuntu launches, create your **UNIX username** and **password**.

------------------------------------------------------------------------

## 2. Update Ubuntu Packages

``` bash
sudo apt update
sudo apt upgrade -y
```

------------------------------------------------------------------------

## 3. Install Required Build Tools

These packages ensure Ruby, OpenSSL, and Jekyll build correctly:

``` bash
sudo apt install -y   build-essential   autoconf   bison   libssl-dev   libreadline-dev   zlib1g-dev   libyaml-dev   libffi-dev   libgdbm-dev   libncurses5-dev   pkg-config   git curl
```

------------------------------------------------------------------------

## 4. Install rbenv (Ruby Version Manager)

``` bash
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init - bash)"' >> ~/.bashrc
exec "$SHELL"
```

### Install ruby-build plugin

``` bash
mkdir -p ~/.rbenv/plugins
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
exec "$SHELL"
```

------------------------------------------------------------------------

## 5. Install Ruby

List available Ruby versions:

``` bash
rbenv install -l
```

Install a stable version (example):

``` bash
rbenv install 3.4.7
rbenv global 3.4.7
rbenv rehash
```

Verify:

``` bash
ruby -v
```

------------------------------------------------------------------------

## 6. Install Bundler and Jekyll

``` bash
gem install bundler jekyll
rbenv rehash
jekyll -v
```

------------------------------------------------------------------------

## 7. Create a Development Directory

``` bash
mkdir -p ~/dev
cd ~/dev
```

------------------------------------------------------------------------

## 8. Create a New Jekyll Site

``` bash
jekyll new mysite
cd mysite
bundle install
```

------------------------------------------------------------------------

## 9. Run Jekyll Server

``` bash
bundle exec jekyll serve
```

Open your browser to:

    http://localhost:4000

Press **Ctrl + C** to stop the server.

------------------------------------------------------------------------

## 10. Build Site for Deployment

``` bash
bundle exec jekyll build
```

Your static site appears in:

    ./_site/

Upload this folder to WHM/cPanel, GitHub Pages, or any static host.

------------------------------------------------------------------------

## 11. Recommended Workflow

-   Use **VS Code + WSL extension**
-   Edit project via:

``` bash
cd ~/dev/mysite
code .
```

This keeps Ruby/Linux in WSL and editing on Windows --- the best
combination.

------------------------------------------------------------------------

## Finished!

You now have a perfect Jekyll development environment on Windows 11 via
WSL2.
