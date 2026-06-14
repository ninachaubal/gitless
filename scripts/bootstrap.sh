#!/usr/bin/env bash
# Check (and where safe, repair) the toolchain a person needs to keep their
# work backed up. Speaks plainly; never auto-runs installs that need a password
# or a browser — it hands those off clearly.

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$HERE/lib/common.sh"
set +e  # we want to report on every check, not stop at the first problem

need_action=0

# How would we install something on this machine?
install_hint() {
  local pkg="$1"
  if   command -v apt-get >/dev/null 2>&1; then echo "sudo apt-get install -y $pkg"
  elif command -v dnf     >/dev/null 2>&1; then echo "sudo dnf install -y $pkg"
  elif command -v pacman  >/dev/null 2>&1; then echo "sudo pacman -S --noconfirm $pkg"
  elif command -v brew    >/dev/null 2>&1; then echo "brew install $pkg"
  else echo ""; fi
}

# 1. The thing that tracks your saves ---------------------------------------
if command -v git >/dev/null 2>&1; then
  ok "Your work can be saved and tracked. (ready)"
else
  hint="$(install_hint git)"
  oops "The piece that tracks your saves isn't installed yet."
  [ -n "$hint" ] && info "I can install it for you with: $hint" || \
    info "Install it from https://git-scm.com/downloads"
  need_action=1
fi

# 2. The connection to GitHub (your backup service) -------------------------
if command -v gh >/dev/null 2>&1; then
  ok "The connection to GitHub is installed. (ready)"
  if gh auth status >/dev/null 2>&1; then
    ok "You're signed in to GitHub."
    # Borrow identity from GitHub so saves are attributed, if not set yet.
    if [ -z "$(git config --global user.name 2>/dev/null)" ]; then
      name="$(gh api user -q .name 2>/dev/null)"
      login="$(gh api user -q .login 2>/dev/null)"
      [ -n "$name" ] && git config --global user.name "$name"
      [ -n "$login" ] && [ -z "$(git config --global user.email 2>/dev/null)" ] && \
        git config --global user.email "${login}@users.noreply.github.com"
    fi
  else
    oops "You're not signed in to GitHub yet."
    say   ""
    say   "GitHub is a free service that keeps a safe copy of your code in the"
    say   "cloud, so you can't lose it and can reach it from anywhere."
    say   "  1. Create a free account at https://github.com (if you don't have one)"
    say   "  2. Sign in here by typing:  ! gh auth login"
    say   "     (pick GitHub.com, then 'Login with a web browser' and follow along)"
    need_action=1
  fi
else
  hint="$(install_hint gh)"
  oops "The connection to GitHub isn't installed yet."
  if [ -n "$hint" ]; then info "I can install it for you with: $hint"
  else info "Install it from https://cli.github.com"; fi
  need_action=1
fi

say ""
if [ "$need_action" -eq 0 ]; then
  ok "Everything's ready — you can start a project whenever you like."
else
  info "A couple of things need doing first (above). Want me to handle them?"
fi
exit "$need_action"
