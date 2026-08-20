# dotfiles

Personal Linux (Ubuntu) config, symlinked into place with `install.sh`.

## Layout

- `home/` mirrors `$HOME` exactly — e.g. `home/.zshrc` maps to `~/.zshrc`,
  `home/.config/i3/config` maps to `~/.config/i3/config`. `install.sh` walks
  this tree and symlinks every file into the matching path under `$HOME`.
- `bin/` — utility scripts, symlinked manually into `~/.local/bin` (not
  handled by `install.sh`) and driven by cron. Includes `claude-notify.sh`
  (desktop notification helper), `phone-notify.sh` (detailed push
  notification to phone via [ntfy](https://ntfy.sh) — see setup below),
  `claude-usage-notify.sh` (pings when Claude plan usage crosses
  80/85/95%), and `disk-space-notify.sh` (pings when free disk space
  drops below 10% or 5%, then again every percent free below that).
- `scripts/` — standalone setup scripts, run manually as needed (not symlinked).

## Bootstrap on a fresh machine

```sh
git clone git@github.com:tejas-techstack/dotfiles.git ~/Tejas_WORK/dotfiles
cd ~/Tejas_WORK/dotfiles
./install.sh
```

Any real file already at a target path gets moved (not deleted) into
`~/.dotfiles-backup/<timestamp>/` before the symlink is created, so it's
always safe to re-run.

### Manual one-time steps

A few tools need to be installed before their configs are useful:

- **oh-my-zsh** — install from https://ohmyz.sh, then re-run `./install.sh`
  so `~/.oh-my-zsh/custom/example.zsh` gets linked.
- **nvim (NvChad)** — this repo only tracks the `lua/custom/` override
  layer, not the NvChad base itself:
  ```sh
  git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
  ```
  then re-run `./install.sh`.
- **powerlevel10k** — `.p10k.zsh` assumes the `powerlevel10k` zsh theme is
  installed (via oh-my-zsh custom themes or your package manager).
- **zoxide / eza / fzf / xclip** — `.zshrc` references these; install via
  your package manager if a fresh shell complains about missing commands.

### Phone notifications (`phone-notify.sh`)

Uses [ntfy](https://ntfy.sh) — a free push service with no account needed.
Delivery is gated by a private, unguessable topic name, generated once and
kept in `~/.config/claude-notify/phone.env` (outside this repo, since this
repo is public):

```sh
mkdir -p -m 700 ~/.config/claude-notify
{ echo "NTFY_TOPIC=$(uuidgen)"; echo "NTFY_SERVER=https://ntfy.sh"; } > ~/.config/claude-notify/phone.env
chmod 600 ~/.config/claude-notify/phone.env
```

Then install the ntfy app and subscribe to `https://ntfy.sh/<the topic
from phone.env>`. Call `phone-notify "Title" "Detailed body"` (optionally
`-p high|urgent` for priority, `-g tag1,tag2` for tags/emoji) from any
script or Claude Code session on this machine. If `phone.env` doesn't
exist, the script silently no-ops — so it's safe to symlink everywhere
even on machines that haven't been set up for phone push yet.

The topic name is the only thing standing between a random person and
your notification feed on the public ntfy.sh server — treat it like a
low-value secret (unguessable, not reused elsewhere, never committed) and
don't rely on it for anything sensitive. For stronger guarantees, point
`NTFY_SERVER` at a self-hosted ntfy instance instead.

## What's deliberately excluded

This repo is public, so anything that's a credential, history file, cache,
or machine-local app state is left out on purpose: SSH/GPG keys, shell
history, browser profiles, IDE workspace state, and API tokens. Only
hand-written/hand-tuned config lives here.
