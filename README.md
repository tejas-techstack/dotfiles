# dotfiles

Personal Linux (Ubuntu) config, symlinked into place with `install.sh`.

## Layout

- `home/` mirrors `$HOME` exactly — e.g. `home/.zshrc` maps to `~/.zshrc`,
  `home/.config/i3/config` maps to `~/.config/i3/config`. `install.sh` walks
  this tree and symlinks every file into the matching path under `$HOME`.
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

## What's deliberately excluded

This repo is public, so anything that's a credential, history file, cache,
or machine-local app state is left out on purpose: SSH/GPG keys, shell
history, browser profiles, IDE workspace state, and API tokens. Only
hand-written/hand-tuned config lives here.
