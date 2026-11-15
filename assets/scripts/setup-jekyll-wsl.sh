#!/usr/bin/env bash
# setup-jekyll-wsl.sh: runs Steps 2-9 of "Installing Jekyll on WSL" in one go.
# https://pspowell.github.io/2026/11/14/installing-jekyll-on-wsl.html
#
# Usage (inside Ubuntu on WSL):
#   bash setup-jekyll-wsl.sh                  # clones <your-github-user>.github.io
#   bash setup-jekyll-wsl.sh owner/repo       # clones a different repo
#
# Safe to re-run: every step checks whether it's already done and skips it.
set -euo pipefail

RUBY_VERSION="3.3.4"          # match https://pages.github.com/versions/
DEV_DIR="$HOME/dev"
REPO_ARG="${1:-}"

say() { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }

# --- Steps 2-3: Ubuntu packages ----------------------------------------------
say "Updating Ubuntu and installing build tools (enter your Ubuntu password if asked)"
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential autoconf bison libssl-dev libreadline-dev \
  zlib1g-dev libyaml-dev libffi-dev libgdbm-dev libncurses-dev pkg-config \
  git curl gh

# --- Step 4: rbenv -------------------------------------------------------------
if [ ! -d "$HOME/.rbenv" ]; then
  say "Installing rbenv"
  git clone https://github.com/rbenv/rbenv.git "$HOME/.rbenv"
  git clone https://github.com/rbenv/ruby-build.git "$HOME/.rbenv/plugins/ruby-build"
else
  say "rbenv already installed; updating its list of Ruby versions"
  git -C "$HOME/.rbenv/plugins/ruby-build" pull --quiet || true
fi
grep -q 'rbenv init' "$HOME/.bashrc" || \
  echo 'eval "$(~/.rbenv/bin/rbenv init - bash)"' >> "$HOME/.bashrc"
eval "$("$HOME/.rbenv/bin/rbenv" init - bash)"

# --- Step 5: Ruby --------------------------------------------------------------
if ! rbenv versions --bare | grep -qx "$RUBY_VERSION"; then
  say "Compiling Ruby $RUBY_VERSION (this takes 5-10 minutes)"
  rbenv install "$RUBY_VERSION"
fi
rbenv global "$RUBY_VERSION"
ruby -v

# --- Step 6: Bundler -----------------------------------------------------------
gem list -i bundler >/dev/null || gem install bundler

# --- Step 7: Git and GitHub login ----------------------------------------------
say "Configuring Git"
if [ -z "$(git config --global user.name || true)" ]; then
  read -rp "Your name for Git commits: " GIT_NAME
  git config --global user.name "$GIT_NAME"
fi
if [ -z "$(git config --global user.email || true)" ]; then
  read -rp "Your email for Git commits (your GitHub noreply address keeps it private): " GIT_EMAIL
  git config --global user.email "$GIT_EMAIL"
fi
git config --global core.autocrlf input
git config --global init.defaultBranch main

if ! gh auth status >/dev/null 2>&1; then
  say "GitHub login: choose GitHub.com, HTTPS, Yes, then 'Login with a web browser'"
  gh auth login
fi
gh auth setup-git

# --- Step 8: clone the site and install its gems --------------------------------
if [ -n "$REPO_ARG" ]; then
  REPO_FULL="$REPO_ARG"
else
  GH_USER="$(gh api user --jq .login)"
  REPO_FULL="$GH_USER/$GH_USER.github.io"
fi
REPO_DIR="$DEV_DIR/${REPO_FULL#*/}"

mkdir -p "$DEV_DIR"
if [ ! -d "$REPO_DIR/.git" ]; then
  say "Cloning $REPO_FULL into $REPO_DIR"
  gh repo clone "$REPO_FULL" "$REPO_DIR"
fi
cd "$REPO_DIR"

if [ ! -f Gemfile ]; then
  say "No Gemfile found; creating one that matches GitHub Pages"
  cat > Gemfile <<'EOF'
source "https://rubygems.org"

gem "github-pages", group: :jekyll_plugins
gem "webrick"   # needed by `jekyll serve` on Ruby 3.x
EOF
fi
grep -q webrick Gemfile || bundle add webrick

say "Installing the site's gems into vendor/bundle"
bundle config set --local path vendor/bundle
bundle install
grep -qx 'vendor/' .gitignore 2>/dev/null || echo 'vendor/' >> .gitignore

# --- Step 9 shortcuts: jserve and jpub ------------------------------------------
if ! grep -q '# jekyll shortcuts' "$HOME/.bashrc"; then
  cat >> "$HOME/.bashrc" <<EOF

# jekyll shortcuts (added by setup-jekyll-wsl.sh)
jserve() {
  cd "$REPO_DIR" || return
  (sleep 6 && explorer.exe http://localhost:4000) &
  bundle exec jekyll serve --livereload "\$@"
}
jpub() {
  cd "$REPO_DIR" || return
  git add . && git commit -m "\${1:-Update site}" && git push
}
EOF
fi

say "All set. Close this terminal and open a new one, then type:  jserve"
say "When you're happy with a change, publish it with:  jpub \"New post\""
