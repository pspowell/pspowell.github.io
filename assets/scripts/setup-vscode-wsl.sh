#!/usr/bin/env bash
# setup-vscode-wsl.sh: WSL side of "Installing VS Code for WSL".
# https://pspowell.github.io/2026/11/16/installing-vscode-for-wsl.html
#
# Usage (inside Ubuntu on WSL, after VS Code is installed on Windows):
#   bash setup-vscode-wsl.sh                          # extensions + ~/dev/pspowell.github.io/.vscode
#   bash setup-vscode-wsl.sh --site ~/dev/mysite      # a different Jekyll site
#   bash setup-vscode-wsl.sh --no-site                # extensions only
#   bash setup-vscode-wsl.sh --force                  # overwrite existing .vscode files
#
# Install-VSCodeWSL.ps1 runs this for you. Safe to re-run.
set -euo pipefail

SITE_DIR="$HOME/dev/pspowell.github.io"
DO_SITE=1
FORCE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --site)    SITE_DIR="${2:?--site needs a path}"; shift 2 ;;
    --no-site) DO_SITE=0; shift ;;
    --force)   FORCE=1; shift ;;
    -h|--help) sed -n '2,11p' "$0"; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done
SITE_DIR="${SITE_DIR/#\~/$HOME}"

say()  { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
note() { printf '    %s\n' "$*"; }
warn() { printf '    \033[1;33m! %s\033[0m\n' "$*"; }

# --- Find the VS Code command ----------------------------------------------------
say "Looking for the VS Code 'code' command"
if ! command -v code >/dev/null 2>&1; then
  for c in /mnt/c/Users/*/AppData/Local/Programs/"Microsoft VS Code"/bin \
           "/mnt/c/Program Files/Microsoft VS Code/bin"; do
    if [ -x "$c/code" ]; then export PATH="$PATH:$c"; break; fi
  done
fi
if ! command -v code >/dev/null 2>&1; then
  warn "'code' not found. Install VS Code on Windows first (Install-VSCodeWSL.ps1 does this),"
  warn "then open a new Ubuntu window and re-run this script."
  exit 1
fi
note "Using: $(command -v code)"

# --- Linux-side extensions ---------------------------------------------------------
# The first run downloads VS Code's server into ~/.vscode-server (about a minute).
say "Installing WSL-side extensions"
for ext in \
  redhat.vscode-yaml \
  DavidAnson.vscode-markdownlint \
  github.vscode-github-actions \
  sissel.shopify-liquid \
  mhutchie.git-graph
do
  code --install-extension "$ext" 2>&1 | grep -vE 'DeprecationWarning|trace-deprecation' | sed 's/^/    /' || true
done

# --- Jekyll site workspace files --------------------------------------------------
write_file() {   # write_file <path>  (content on stdin)
  local path="$1"
  if [ -e "$path" ] && [ "$FORCE" -ne 1 ]; then
    note "Kept existing $(basename "$path") (use --force to replace)"
    cat >/dev/null
  else
    cat > "$path"
    note "Wrote $path"
  fi
}

if [ "$DO_SITE" -eq 1 ]; then
  if [ -f "$SITE_DIR/_config.yml" ]; then
    say "Adding VS Code workspace files to $SITE_DIR/.vscode"
    mkdir -p "$SITE_DIR/.vscode"

    write_file "$SITE_DIR/.vscode/settings.json" <<'EOF'
{
  // Hide build output and installed gems from the file list and search
  "files.exclude": {
    "_site": true,
    ".jekyll-cache": true,
    ".sass-cache": true,
    "vendor": true,
    ".bundle": true
  },
  "search.exclude": {
    "_site": true,
    ".jekyll-cache": true,
    "vendor": true,
    "Gemfile.lock": true
  },
  "files.watcherExclude": {
    "**/_site/**": true,
    "**/.jekyll-cache/**": true,
    "**/vendor/**": true
  },
  "files.associations": {
    "*.html": "liquid"
  }
}
EOF

    write_file "$SITE_DIR/.vscode/tasks.json" <<'EOF'
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Jekyll: serve",
      "type": "shell",
      "command": "bundle exec jekyll serve --livereload",
      "isBackground": true,
      "group": { "kind": "build", "isDefault": true },
      "presentation": { "reveal": "always", "panel": "dedicated" },
      "problemMatcher": {
        "owner": "jekyll",
        "pattern": { "regexp": "^\\s*(?:Liquid )?(?:Error|Exception):\\s+(.*)$", "message": 1 },
        "background": {
          "activeBegin": true,
          "beginsPattern": "Regenerating|Generating\\.\\.\\.",
          "endsPattern": "Server running|done in"
        }
      }
    },
    {
      "label": "Jekyll: build",
      "type": "shell",
      "command": "bundle exec jekyll build",
      "group": "build",
      "problemMatcher": []
    },
    {
      "label": "Jekyll: build for highserv.com",
      "type": "shell",
      "command": "JEKYLL_ENV=production bundle exec jekyll build --config _config.yml,_config.highserv.yml",
      "group": "build",
      "problemMatcher": []
    },
    {
      "label": "Open site in browser",
      "type": "shell",
      "command": "explorer.exe http://localhost:4000 || true",
      "problemMatcher": []
    }
  ]
}
EOF

    write_file "$SITE_DIR/.vscode/jekyll.code-snippets" <<'EOF'
{
  "New post front matter": {
    "scope": "markdown",
    "prefix": "post",
    "description": "Front matter for a new post (Minimal Mistakes, one category)",
    "body": [
      "---",
      "title: \"${1:Post Title}\"",
      "date: $CURRENT_YEAR-$CURRENT_MONTH-$CURRENT_DATE $CURRENT_HOUR:$CURRENT_MINUTE:00 $CURRENT_TIMEZONE_OFFSET",
      "categories: [\"${2|Windows & PC Help,Coding & Automation,AI & Chat Tools,Money & Retirement,Kitchen & Recipes,Home\\, Shop & DIY,Health & Safety,Local Interest,Life & Leisure|}\"]",
      "tags: [${3:tag-one, tag-two}]",
      "excerpt: \"${4:One or two sentences for post lists and search results.}\"",
      "---",
      "",
      "${5:Intro paragraph.}",
      "",
      "## ${6:First Section}",
      "",
      "$0"
    ]
  },
  "Link to another post": {
    "scope": "markdown",
    "prefix": "postlink",
    "body": ["[${1:link text}]({% post_url ${2:YYYY-MM-DD-slug} %})"]
  },
  "Notice box": {
    "scope": "markdown",
    "prefix": "notice",
    "body": ["**${1:Note:}** ${2:text}", "{: .notice--${3|info,warning,success,danger,primary|}}"]
  }
}
EOF
    note "Tip: commit these with  git -C \"$SITE_DIR\" add .vscode && git -C \"$SITE_DIR\" commit -m 'Add VS Code workspace files'"
  else
    say "No Jekyll site at $SITE_DIR; skipping workspace files"
    note "Clone your site first, or pass --site <path>."
  fi
fi

say "Done"
note "Open your site in VS Code:  cd \"$SITE_DIR\" && code ."
note "Then: Ctrl+Shift+B serves the site; type 'post' in a new .md file for front matter."
