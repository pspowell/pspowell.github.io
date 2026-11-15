---
title: "How I migrated to Minimal-Mistakes"
date: 2026-11-15 16:00:00 -0500
categories: ["Coding & Automation"]
tags: [jekyll, minimal-mistakes, github-pages, wsl, github-actions, cpanel, rsync]
excerpt: "Start to finish: snapshotting a 150-post Jekyll blog, moving it from Minima to Minimal Mistakes without breaking a single link, sorting it into topics, and auto-publishing a second copy to my own cPanel host."
---

This site ran on Jekyll's default **Minima** theme for three years. It worked, but 150 posts in one long date-ordered list made it hard to find anything. Over a weekend I moved it to **[Minimal Mistakes](https://mmistakes.github.io/minimal-mistakes/)**, sorted every post into topics, kept every old link working, and set it up so each push also publishes a copy to **www.highserv.com** on my VeeroTech hosting.

This is the whole process, in the order I'd do it again.

## The Plan

1. Snapshot the existing site so rollback is one command.
2. Get a local Jekyll build that matches GitHub Pages exactly.
3. Do the migration on a branch, previewed locally, while the live site stays untouched.
4. Merge when it looks right.
5. Add automatic publishing to a second host.

## 1. Snapshot the Current Site

Before touching anything, freeze the current state three ways: a tag, a branch, and a downloadable release.

```bash
cd ~/dev/pspowell.github.io
git pull
git tag -a minima-final-2026-11-14 -m "Site as-is before Minimal Mistakes"
git push origin minima-final-2026-11-14
git branch archive/minima && git push origin archive/minima
```

Then on GitHub: **Releases → Draft a new release**, choose the tag, give it a title, and **Publish release**. GitHub attaches a zip of the whole site automatically, which makes a handy offline copy.

If anything ever goes badly wrong:

```bash
git checkout main && git reset --hard origin/archive/minima && git push --force
```

## 2. A Local Build That Matches GitHub Pages

I build on Windows 11 under WSL2. The full setup is in [Installing Jekyll on WSL]({% post_url 2025-11-23-installing-jekyll-on-wsl %}). The two things that matter most:

- **Use GitHub's Ruby version and the `github-pages` gem**, not a global `gem install jekyll`. GitHub Pages runs Jekyll 3.10 on Ruby 3.3; a global install gives you Jekyll 4 and builds that don't match. Current versions are listed at [pages.github.com/versions](https://pages.github.com/versions/).
- **Keep the repo in the Linux filesystem** (`~/dev`), not under `/mnt/c`. Builds are much faster and live reload actually notices your edits.

My `Gemfile` is just:

```ruby
source "https://rubygems.org"

gem "github-pages", group: :jekyll_plugins
gem "webrick"   # needed by `jekyll serve` on Ruby 3.x
```

My old `Gemfile.lock` pinned Jekyll 4 from years ago and conflicted with `github-pages`, so I deleted it and let `bundle install` generate a fresh one.

## 3. Work on a Branch, Preview Side by Side

GitHub Pages builds only `main`, so I did all the theme work on a `minimal-mistakes` branch. To preview it without disturbing my normal working folder, I gave the branch its own folder with a **git worktree**, and added two shortcuts to `~/.bashrc`:

```bash
MM_MAIN="$HOME/dev/pspowell.github.io"
MM_DIR="$HOME/dev/pspowell.github.io-mm"
MM_BRANCH="minimal-mistakes"

# mpull: create/update the branch's preview folder
mpull() {
  git -C "$MM_MAIN" fetch origin "$MM_BRANCH" || return
  if [ ! -d "$MM_DIR" ]; then
    if [ "$(git -C "$MM_MAIN" branch --show-current)" = "$MM_BRANCH" ]; then
      git -C "$MM_MAIN" checkout main || return
    fi
    if git -C "$MM_MAIN" show-ref --verify --quiet "refs/heads/$MM_BRANCH"; then
      git -C "$MM_MAIN" worktree add "$MM_DIR" "$MM_BRANCH" || return
    else
      git -C "$MM_MAIN" worktree add --track -b "$MM_BRANCH" "$MM_DIR" "origin/$MM_BRANCH" || return
    fi
  fi
  cd "$MM_DIR" || return
  git pull --ff-only origin "$MM_BRANCH" || return
  bundle config set --local path "$MM_MAIN/vendor/bundle"   # share installed gems
  bundle check >/dev/null 2>&1 || bundle install
}

# mserve: preview the branch on port 4001
mserve() {
  cd "$MM_DIR" 2>/dev/null || { echo "Run mpull first."; return 1; }
  (sleep 8 && explorer.exe http://localhost:4001) &
  bundle exec jekyll serve --livereload --port 4001 --livereload-port 35730 "$@"
}
```

With that, the live version runs on `localhost:4000` and the new theme on `localhost:4001`, side by side.

## 4. Configure Minimal Mistakes

Minimal Mistakes works on GitHub Pages as a **remote theme**, so there's nothing to install. The key parts of my `_config.yml`:

```yaml
remote_theme: "mmistakes/minimal-mistakes@4.28.1"   # pinned so theme updates can't break the site
minimal_mistakes_skin: "default"

search: true
breadcrumbs: false   # post breadcrumbs link to /YYYY/ pages that don't exist

plugins:
  - jekyll-remote-theme
  - jekyll-paginate
  - jekyll-sitemap
  - jekyll-gist
  - jekyll-feed
  - jekyll-include-cache
  - jekyll-redirect-from

paginate: 10
paginate_path: /page:num/

category_archive:
  type: liquid
  path: /categories/
tag_archive:
  type: liquid
  path: /tags/

defaults:
  - scope:
      path: ""
      type: posts
    values:
      layout: single
      author_profile: true
      read_time: true
      share: true
      related: true
      toc: true
      toc_sticky: true
      toc_label: "On this page"
```

I also filled in the `author:` block (name, photo, bio, links), which becomes the sidebar on every post.

**Pin the theme version.** `@4.28.1` means an upstream change can't break the site overnight. Bump it on purpose when you want new features.
{: .notice--info}

## 5. Sort the Posts into Topics

The biggest improvement was organizing 146 posts into nine topics:

| Topic | What's in it |
|---|---|
| Windows & PC Help | Fixing, imaging, upgrading Windows |
| Coding & Automation | PowerShell, Python, Docker, Excel, Jekyll |
| AI & Chat Tools | ChatGPT, Claude, Gemini |
| Money & Retirement | Social Security, Medicare, taxes, investing |
| Kitchen & Recipes | Breads, barbecue, cocktails |
| Home, Shop & DIY | Woodworking, welding, tractors |
| Health & Safety | Health, privacy, rights |
| Local Interest | Champaign County topics |
| Life & Leisure | Careers, games, sports, hobbies |

Each post gets exactly one category in its front matter:

```yaml
categories: ["Home, Shop & DIY"]
```

Each topic also gets its own page in `_pages/`, using the theme's `category` layout:

```yaml
---
title: "Home, Shop & DIY"
layout: category
permalink: /categories/home-shop-diy/
taxonomy: "Home, Shop & DIY"
entries_layout: list
---
```

Then there's an all-topics page (`layout: categories`, permalink `/categories/`), a tags page, a posts-by-year page, and a search page. The top menu lives in `_data/navigation.yml`.

The home page (`index.html`, which must be HTML for pagination to work) uses `layout: home` with a `feature_row` of nine topic tiles, each with a **Browse** button, followed by the ten most recent posts.

## 6. Keep Every Old Link Working

This was the part most worth getting right. Jekyll's default URL pattern puts a post's categories in its address:

```
/:categories/:year/:month/:day/:title.html
```

Most of my posts had no categories, so their URLs were just `/2025/11/23/...`. A few older ones had categories like `tech` or `recipes`, giving `/tech/2023/11/23/...`. If I had added the new categories under the default pattern, **every post's URL would have changed**.

The fix:

1. **Drop categories from the URL pattern.** Posts that never had categories keep exactly the same address.

   ```yaml
   permalink: /:year/:month/:day/:title:output_ext
   ```

2. **Redirect the posts that did have categories.** For those 19 posts, add their old address with the `jekyll-redirect-from` plugin, which GitHub Pages supports:

   ```yaml
   redirect_from:
     - "/tech/2023/11/23/Activate-Windows-God-Mode.html"
   ```

3. **Pin the time zone.** A post dated late in the evening Eastern time falls on the next day in UTC, which is what GitHub builds in. Setting `timezone: Etc/UTC` makes local builds produce the same dates, and the same URLs, as GitHub.

**Check your old URLs against the live site before you merge.** A post's URL date comes from its front-matter `date:`, not the filename, and time zones can shift it by a day. I confirmed each redirect target against the live site.
{: .notice--warning}

## 7. Clean Up the Front Matter

A few things that worked in Minima break or look wrong in Minimal Mistakes:

- **Remove `layout: post` and `layout: page`.** Minimal Mistakes has neither layout, so those posts render without styling. With the `defaults:` block above, posts don't need a `layout:` line at all.
- **Don't repeat the title as a `#` heading.** The theme already shows the title, so a body that starts with `# Same Title` displays it twice. I removed those.
- **Add an `excerpt:`.** Post lists show the excerpt, and the default is the first paragraph. For posts that open with a heading or a code block, that's useless, so I added a one- or two-sentence `excerpt:` to each post.
- Fix leftovers such as `**` inside titles.

With 146 posts, I scripted these edits rather than doing them by hand, then reviewed the diff before committing.

## 8. Merge and Go Live

After previewing with `mserve`, merging is a normal pull request:

1. On GitHub, click **Compare & pull request** for the branch (or **Pull requests → New pull request** with base `main` and compare `minimal-mistakes`).
2. Click **Create pull request**, then **Merge pull request**, then **Confirm merge**.
3. Watch **Actions** (or **Deployments → github-pages**) for the build to go green, about 1–2 minutes.
4. Press **Ctrl+F5** on the live site, because browsers and the CDN cache the old pages for a few minutes.

## 9. Auto-Publish a Copy to My Own Host

I also wanted the same site at **www.highserv.com**, hosted on VeeroTech (cPanel, LiteSpeed). Instead of uploading by hand, a GitHub Actions workflow builds the site with that domain's settings and syncs it over SSH every time `main` changes. GitHub Pages keeps building separately, as before.

### Domain-specific build settings

A second config file overrides only the URL, so canonical links, the sitemap and redirects point to the right domain:

```yaml
# _config.highserv.yml
url: "https://www.highserv.com"
```

It's used by building with `--config _config.yml,_config.highserv.yml`, and listed under `exclude:` in `_config.yml` so it isn't published.

An `.htaccess` (added to `include:` in `_config.yml`, since Jekyll skips dotfiles) handles the server side:

```apache
ErrorDocument 404 /404.html

<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteCond %{REQUEST_URI} !^/\.well-known/
  RewriteCond %{HTTPS} off [OR]
  RewriteCond %{HTTP_HOST} !^www\. [NC]
  RewriteRule ^ https://www.highserv.com%{REQUEST_URI} [L,R=301]
</IfModule>
```

The `.well-known` exception keeps cPanel's free SSL certificates renewing. GitHub Pages ignores the file.

### A deploy-only SSH key

Use a key just for GitHub, never your personal one. In WSL:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/highserv_deploy -N "" -C "github-actions-highserv"
cat ~/.ssh/highserv_deploy.pub
```

In cPanel, go to **SSH Access → Manage SSH Keys → Import Key**, paste the public key, then **Manage → Authorize**. Then capture the server's host key so the workflow can verify it's talking to the right machine:

```bash
ssh-keyscan -p PORT your.server.name
```

### Secrets and a safety switch

In the repo, under **Settings → Secrets and variables → Actions**:

| Secrets tab | Value |
|---|---|
| `HIGHSERV_SSH_KEY` | the private key (`cat ~/.ssh/highserv_deploy`) |
| `HIGHSERV_KNOWN_HOSTS` | the `ssh-keyscan` output |
| `HIGHSERV_HOST` | server name |
| `HIGHSERV_PORT` | SSH port |
| `HIGHSERV_USER` | cPanel username |

On the **Variables** tab, `HIGHSERV_LIVE` controls whether the workflow really uploads. Anything other than `true`, or no variable at all, means **dry run**: the workflow shows what it would change and uploads nothing.

### The workflow

`.github/workflows/deploy-highserv.yml`:

{% raw %}
```yaml
name: Deploy to highserv.com

on:
  push:
    branches: [main]
  workflow_dispatch:
    inputs:
      dry_run:
        description: "Dry run (show changes, upload nothing)"
        type: boolean
        default: true

concurrency:
  group: deploy-highserv
  cancel-in-progress: false

permissions:
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-24.04
    timeout-minutes: 20
    steps:
      - uses: actions/checkout@v4

      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: "3.3"
          bundler-cache: true

      - name: Build for www.highserv.com
        env:
          JEKYLL_ENV: production
        run: bundle exec jekyll build --config _config.yml,_config.highserv.yml

      - name: Set up SSH key
        env:
          SSH_KEY: ${{ secrets.HIGHSERV_SSH_KEY }}
          KNOWN_HOSTS: ${{ secrets.HIGHSERV_KNOWN_HOSTS }}
        run: |
          install -m 700 -d ~/.ssh
          printf '%s\n' "$SSH_KEY" > ~/.ssh/highserv
          chmod 600 ~/.ssh/highserv
          printf '%s\n' "$KNOWN_HOSTS" > ~/.ssh/known_hosts

      - name: Sync to server
        env:
          HOST: ${{ secrets.HIGHSERV_HOST }}
          PORT: ${{ secrets.HIGHSERV_PORT }}
          USER: ${{ secrets.HIGHSERV_USER }}
          LIVE: ${{ vars.HIGHSERV_LIVE }}
          MANUAL_DRY_RUN: ${{ github.event_name == 'workflow_dispatch' && inputs.dry_run }}
        run: |
          DRY="--dry-run"
          if [ "$LIVE" = "true" ] && [ "$MANUAL_DRY_RUN" != "true" ]; then DRY=""; fi
          echo "Mode: ${DRY:-LIVE UPLOAD}"
          rsync -az --delete --itemize-changes $DRY \
            --exclude '.well-known' --exclude 'cgi-bin' \
            -e "ssh -i ~/.ssh/highserv -p $PORT -o IdentitiesOnly=yes -o StrictHostKeyChecking=yes" \
            _site/ "$USER@$HOST:public_html/"

      - name: Remove SSH key
        if: always()
        run: rm -f ~/.ssh/highserv
```
{% endraw %}

Two details that matter:

- **Pin the runner.** `ubuntu-latest` moved to a release where `setup-ruby` didn't have Ruby 3.3.x yet, so the build failed at the Ruby step. `ubuntu-24.04` with `ruby-version: "3.3"` is stable.
- **`--delete` makes `public_html` an exact copy of the site.** Anything else in that folder gets removed. Run a dry run first and read every `*deleting` line in the log. Anything you want to keep (other scripts, an FTP account's folder, server config files) gets its own `--exclude`.

### Going live

1. Push the workflow. The first run is a dry run. Open **Actions → Deploy to highserv.com → Sync to server** and review the changes.
2. Add `--exclude` entries until the dry run shows **0 deletions** of anything you care about.
3. Back up `public_html` from the server:
   ```bash
   ssh highserv 'tar czf ~/public_html-backup-$(date +%F).tgz public_html'
   ```
4. Create the variable `HIGHSERV_LIVE` = `true`.
5. **Actions → Deploy to highserv.com → Run workflow**, untick **Dry run**, and run it.

From then on, every push updates both sites within a couple of minutes.

## 10. Rules for Future Posts

To keep new posts consistent, I added a `CLAUDE.md` to the repo root (and to `exclude:` so it isn't published). It records the conventions: filename format, front matter with exactly one of the nine categories, no `layout:` line, no repeated title heading, and the settings that must not change because URLs depend on them (`permalink`, `timezone`, category names). It's written for my AI assistant, but it's just as useful as a checklist for me.

A new post now looks like this:

```yaml
---
title: "Post Title"
date: 2026-11-15 16:00:00 -0500
categories: ["Coding & Automation"]
tags: [jekyll, github-pages]
excerpt: "One or two sentences for post lists and search results."
---

Intro paragraph...

## First Section
```

## Checklist

- [ ] Tag, branch and release snapshot of the old site
- [ ] Local build with the `github-pages` gem and GitHub's Ruby version
- [ ] Theme work on a branch, previewed with a worktree
- [ ] `remote_theme` pinned to a version
- [ ] One category per post, with category pages and navigation
- [ ] `permalink` without `:categories`, plus `redirect_from` for posts whose URLs changed
- [ ] `timezone: Etc/UTC` so local and GitHub dates agree
- [ ] `layout: post` / `layout: page` removed; excerpts added
- [ ] Old URLs spot-checked on the live site after merging
- [ ] Second host: separate config, deploy-only key, secrets, dry run, excludes, then live
