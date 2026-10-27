# qFioofa-Herdr

Personal [Herdr](https://herdr.dev) config: Yugen Ash theme, tmux/wezterm-style
keys, a compact agent sidebar, and popups for the tools I use every day.

Herdr version: `0.9.3`.

## Install

```bash
bash ./scripts/deploy.sh
```

The script:

1. backs up `~/.config/herdr/config.toml`;
2. installs `src/config.toml`;
3. validates it with `herdr config check`;
4. reloads a running Herdr server;
5. installs Herdr integrations for `opencode`, `claude`, and `codex` when those
   binaries are in `PATH`.

Skip integrations:

```bash
bash ./scripts/deploy.sh --no-integrations
```

Apply config manually after editing:

```bash
herdr config check
herdr server reload-config
```

Herdr keeps runtime state (`session.json`, logs, snapshots) in `~/.config/herdr`,
so this repo deploys only `config.toml` and never symlinks or removes the whole
directory.

## Nix

The flake exposes a Home Manager module that writes only
`~/.config/herdr/config.toml`:

```nix
# flake inputs
qFioofa-Herdr.url = "github:qFioofa/qFioofa-Herdr";

# home configuration
imports = [ inputs.qFioofa-Herdr.homeManagerModules.default ];
```

The Herdr package is installed separately (for example from
`github:herdrdev/herdr`).

## Theme

`catppuccin` is used as the base and every exposed token is overridden with the
Yugen Ash palette. `auto_switch` is off because Yugen Ash has no light variant.

| Token | Value |
| --- | --- |
| `accent`, `ui.accent` | `#FFBE89` |
| `panel_bg`, `sidebar_bg` | `#151515` |
| `active_row_bg`, `selection_bg` | `#303030` |
| `surface0`, `surface_dim` | `#1E1E1E` |
| `surface1` | `#303030` |
| `overlay0` | `#696969` |
| `overlay1` | `#A9A9A9` |
| `text` | `#FAFAFA` |
| `subtext0` | `#D4D4D4` |
| `mauve` | `#C678DD` |
| `green` | `#7EAB8E` |
| `yellow` | `#FFF2AF` |
| `red` | `#F57A7A` |
| `blue` | `#79A0AA` |
| `teal` | `#8DD3C3` |
| `peach` | `#FFBE89` |

UI defaults in this config:

- top tab bar with clock, date, hostname, and zoom indicator;
- distinct symbols instead of dots for agent states;
- expanded 28-column sidebar with Space branch/git status and Agent rows;
- pane gaps and automatic pane borders;
- new tabs prompt for a name, matching the tmux workflow.

## Keys

The prefix matches tmux: `Ctrl+m` primary, `Alt+n` fallback. Both enter the same
prefix mode.

> `Ctrl+m` is Enter at the byte level. It works only when the outer terminal
> distinguishes it from Enter; otherwise `Alt+n` remains the safe prefix.

### Panes

| Key | Action |
| --- | --- |
| `prefix+h/j/k/l` | Focus pane left/down/up/right |
| `Alt+h/j/k/l` | Focus pane without the prefix |
| `prefix+Shift+h/j/k/l` | Swap pane |
| `prefix+v`, `prefix+%`, `prefix+\` | Split side by side |
| `prefix+-`, `prefix+"` | Split stacked |
| `prefix+<`, `prefix+>`, `prefix+_`, `prefix++` | Resize pane |
| `prefix+r` | Resize mode |
| `prefix+z` | Zoom pane |
| `prefix+x` | Close pane |
| `prefix+[` | Copy mode |
| `prefix+Shift+e` | Open scrollback in `$EDITOR` |
| `prefix+Tab` | Cycle pane |

### Tabs and Spaces

| Key | Action |
| --- | --- |
| `prefix+c` | New tab (prompts for a name) |
| `prefix+n` / `prefix+p` | Next / previous tab |
| `prefix+1..9` | Switch to tab |
| `prefix+Shift+t` | Rename tab |
| `prefix+Shift+x` | Close tab |
| `prefix+w`, `prefix+e` | Workspace picker |
| `prefix+g` | Session navigator |
| `prefix+Shift+n` | New Space |
| `prefix+Shift+w` | Rename Space |
| `prefix+Shift+d` | Close Space |
| `prefix+Shift+1..9` | Switch Space |
| `prefix+Shift+g` | New Git worktree |
| `prefix+Shift+o` | Open worktree |
| `prefix+Alt+w` | Remove worktree |
| `prefix+b` | Toggle sidebar |

### Agents and tools

| Key | Action |
| --- | --- |
| `prefix+Alt+1..9` | Focus Agent by index |
| `prefix+Alt+j` / `prefix+Alt+k` | Next / previous Agent |
| `prefix+Alt+g` | `lazygit` popup |
| `prefix+Alt+d` | `lazydocker` popup |
| `prefix+t` | Scratch terminal popup |
| `prefix+q` | Detach |
| `prefix+Shift+r` | Reload config |
| `prefix+?` | Keybinding help |

### Russian layout

Bindings that use bare letters are mirrored for ЙЦУКЕН by physical key:

| Latin | Russian |
| --- | --- |
| `h` | `р` |
| `j` | `о` |
| `k` | `л` |
| `l` | `д` |
| `"` | `э` |
| `<` | `б` |
| `>` | `ю` |

This applies to pane focus/swap, navigate mode, and resize.

## Workflow

- One Herdr **Space** per repository or task, instead of a tmux session.
- **Tabs** split a Space into `agents`, `logs`, `server`, and similar views.
- Herdr keeps the server running when the client detaches; session snapshots
  replace tmux-resurrect/continuum.
- `workspace_picker` replaces tmux-sessionx.
- `prefix+t` replaces tmux-floax.
- `Alt+h/j/k/l` replaces vim-tmux-navigator for pane movement.
- Agent state comes from `herdr integration install` (`opencode`, `claude`,
  `codex`), so the sidebar shows working/blocked/done without extra plugins.

## Rollback

Every deploy creates `config.toml.bak.<timestamp>` next to the config. Restore it
and reload:

```bash
cp ~/.config/herdr/config.toml.bak.<timestamp> ~/.config/herdr/config.toml
herdr server reload-config
```
