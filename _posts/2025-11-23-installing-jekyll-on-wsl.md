---
layout: post
title: "Installing Jekyll on WSL (Best Practices Guide)"
date: 2025-11-23
last_modified_at: 2026-11-14
tags: [jekyll, wsl, ruby, windows11, github-pages, tutorial]
---

# Installing Jekyll on WSL (Windows Subsystem for Linux)

This guide sets up **Jekyll** on Windows 11 using **WSL2 + Ubuntu 24.04**, configured to match what **GitHub Pages** actually builds with, so a site that works on your PC works when you push it.

> **Updated November 2026:** Ruby is now pinned to GitHub Pages' version, Jekyll is installed per-site with Bundler instead of globally, the package list is fixed for Ubuntu 24.04, and there are new sections on working with an existing GitHub Pages repo and on troubleshooting.

------------------------------------------------------------------------

## 1. Install WSL2 + Ubuntu

Open **PowerShell as Administrator** and run:

```powershell
wsl --install -d Ubuntu-24.04
```

Restart if prompted. When Ubuntu launches, create your **UNIX username** and **password**.

Confirm it is running under WSL **version 2**:

```powershell
wsl -l -v
```

If WSL was already installed, bring it up to date first:

```powershell
wsl --update
```

------------------------------------------------------------------------

## 2. Update Ubuntu Packages

```bash
sudo apt update && sudo apt upgrade -y
```

------------------------------------------------------------------------

## 3. Install Required Build Tools

These packages let Ruby compile cleanly:

```bash
sudo apt install -y build-essential autoconf bison libssl-dev libreadline-dev \
  zlib1g-dev libyaml-dev libffi-dev libgdbm-dev libncurses-dev pkg-config git curl
```

> **Note:** Older guides (including the first version of this one) list `libncurses5-dev`. That package no longer exists in Ubuntu 24.04; `libncurses-dev` replaces it.

------------------------------------------------------------------------

## 4. Install rbenv (Ruby Version Manager)

```bash
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'eval "$(~/.rbenv/bin/rbenv init - bash)"' >> ~/.bashrc
git clone https://github.com/rbenv/ruby-build.git "$(~/.rbenv/bin/rbenv root)"/plugins/ruby-build
exec "$SHELL"
```

Check it:

```bash
rbenv --version
```

------------------------------------------------------------------------

## 5. Install Ruby (Match GitHub Pages)

GitHub Pages builds with a specific Ruby version, listed at [pages.github.com/versions](https://pages.github.com/versions/). As of this update it is **Ruby 3.3.4**. Using the same version locally avoids "works on my machine" surprises.

```bash
rbenv install 3.3.4
rbenv global 3.3.4
ruby -v
```

> If you host somewhere other than GitHub Pages (for example cPanel), any current Ruby 3.3+ is fine.

------------------------------------------------------------------------

## 6. Install Bundler (Not Jekyll)

```bash
gem install bundler
```

Don't `gem install jekyll` globally. Each site's **Gemfile** decides its Jekyll version, and `bundle exec` runs exactly that version. GitHub Pages uses Jekyll 3.10. A global `jekyll new` gives you Jekyll 4, which GitHub Pages does not run, so the two get out of step.

------------------------------------------------------------------------

## 7. Configure Git

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global core.autocrlf input
git config --global init.defaultBranch main
```

`core.autocrlf input` stops Windows line endings from sneaking into your repo.

To push to GitHub from WSL, the easiest route is the GitHub CLI:

```bash
sudo apt install -y gh
gh auth login
```

------------------------------------------------------------------------

## 8. Work on Your Existing GitHub Pages Site

Clone the repo into the **Linux file system** (`~/dev`), **not** `/mnt/c/...`. Builds are many times faster there, and automatic rebuilds actually detect your edits.

```bash
mkdir -p ~/dev && cd ~/dev
git clone https://github.com/USERNAME/USERNAME.github.io.git
cd USERNAME.github.io
```

Your **Gemfile** should use the `github-pages` gem so you get the same Jekyll and plugins GitHub uses:

```ruby
source "https://rubygems.org"

gem "github-pages", group: :jekyll_plugins
gem "webrick"   # needed by `jekyll serve` on Ruby 3.x
```

Install the gems into the project folder (keeps them out of your system Ruby):

```bash
bundle config set --local path vendor/bundle
bundle install
```

Add `vendor/` to `.gitignore`, and to the `exclude:` list in `_config.yml`, so Jekyll doesn't try to build it.

### Starting a brand-new site instead

```bash
mkdir -p ~/dev/mysite && cd ~/dev/mysite
bundle init
bundle add github-pages --group jekyll_plugins
bundle add webrick
bundle exec jekyll new . --force --skip-bundle
bundle install
```

`jekyll new --force` rewrites the Gemfile. Open it, comment out the `gem "jekyll"` line, uncomment the `gem "github-pages"` line, make sure `gem "webrick"` is there, then run `bundle install` again. This leaves only one Jekyll version in play.

------------------------------------------------------------------------

## 9. Run the Local Server

```bash
bundle exec jekyll serve --livereload
```

Open in your Windows browser:

    http://localhost:4000

The page reloads automatically when you save a file. Press **Ctrl + C** to stop.

Useful extra flags:

| Flag | Purpose |
|---|---|
| `--drafts` | Also show posts in `_drafts/` |
| `--future` | Show posts dated in the future |
| `--incremental` | Faster rebuilds on large sites |
| `--force_polling` | Needed only if the site lives under `/mnt/c` |

------------------------------------------------------------------------

## 10. Publish

**GitHub Pages:** commit and push the source. Don't upload `_site/`; GitHub builds the site for you.

```bash
git add .
git commit -m "New post"
git push
```

**cPanel/WHM or another static host:** build the site and upload the contents of `_site/`:

```bash
JEKYLL_ENV=production bundle exec jekyll build
```

------------------------------------------------------------------------

## 11. Recommended Workflow

- Install **VS Code** on Windows plus the **WSL** extension.
- Open the project from inside Ubuntu:

```bash
cd ~/dev/USERNAME.github.io
code .
```

VS Code runs its tools inside Linux and shows the editor on Windows. Run `bundle exec jekyll serve --livereload` in the VS Code terminal and keep the browser open beside it.

- In Windows Explorer, your WSL files appear under **Linux → Ubuntu-24.04** (or `\\wsl$\Ubuntu-24.04\home\<you>\dev`).

------------------------------------------------------------------------

## 12. Keeping It Current

```bash
bundle update github-pages   # pull the versions GitHub currently uses
git pull                     # stay in sync with the repo
```

When GitHub Pages moves to a new Ruby version, install it with `rbenv install <version>`, run `rbenv global <version>`, then `bundle install`.

------------------------------------------------------------------------

## Troubleshooting

| Symptom | Fix |
|---|---|
| `cannot load such file -- webrick` | `bundle add webrick` |
| `jekyll: command not found` | Run it as `bundle exec jekyll ...` |
| Gem install fails compiling native extensions | Re-run the Step 3 package install |
| Edits don't trigger a rebuild | Move the site out of `/mnt/c` into `~/dev`, or add `--force_polling` |
| Port 4000 already in use | `bundle exec jekyll serve --port 4001` |
| Site looks right locally but not on GitHub | Check the **Actions** tab for the Pages build log; make sure every plugin you use is on the [GitHub Pages supported list](https://pages.github.com/versions/) |
| Remote theme fails to load locally | Make sure `jekyll-remote-theme` is under `plugins:` in `_config.yml` and you're online |

------------------------------------------------------------------------

## Finished!

You now have a Jekyll environment on Windows 11 that matches GitHub Pages, so what you preview at `localhost:4000` is what you'll get when you push.
