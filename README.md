# Neovim config

For Neovim 0.12 (stable). Plugins are managed by the built-in `vim.pack`, with
versions pinned in `nvim-pack-lock.json`.

| Path | What |
|---|---|
| `init.lua` | Loads `config/` and the plugins; only surround and the VS Code keymaps inside vscode-neovim |
| `lua/config/` | Options, keymaps, commands, UI (ui2, LSP progress), vscode-neovim keymaps |
| `lua/plugins/` | One file per plugin: its `vim.pack.add` and its setup; `init.lua` sets the order |
| `lsp/`, `after/lsp/` | LSP server definitions and settings on top of nvim-lspconfig |
| `ftplugin/java.lua` | jdtls via nvim-jdtls, behind [Outrigger](https://github.com/Tylopilus/outrigger) when it is built |
| `lua/format_changed.lua` | `<leader>f`: format only the lines changed since the last commit |
| `extras/` | Files that live outside `~/.config/nvim`, symlinked into place (see below) |

## New machine

### 1. Tools

```sh
brew install neovim ripgrep lazygit tree-sitter-cli fnm maven
```

Also needed: git, a C compiler and make (`sudo apt install build-essential`)
for the treesitter parsers, and a [Nerd Font](https://www.nerdfonts.com) in
the terminal.

Java: a JDK 21 or newer, e.g. via [SDKMAN](https://sdkman.io)
(`sdk install java 21.0.2-open`). jdtls uses `$JAVA_HOME`, which SDKMAN sets,
or else the `java` on `PATH`.

### 2. Node and global npm packages

Global npm packages go to one place for all Node versions, so they keep working
when switching versions with fnm:

```sh
fnm install --lts
npm config set prefix ~/.npm-global
```

In `~/.zshrc`, before `eval "$(fnm env --use-on-cd)"`:

```sh
export PATH="$HOME/.npm-global/bin:$PATH"
```

### 3. Prettier

Formatting uses the global prettier with the XML plugin and a
[fork of prettier-plugin-java](https://github.com/Tylopilus/prettier-java) that
can format only some lines (`lineRanges`):

```sh
npm install -g prettier @prettier/plugin-xml \
  https://github.com/Tylopilus/prettier-java/releases/download/v2.11.0-lineranges.2/prettier-plugin-java-2.11.0-lineranges.2.tgz
```

Take the newest `-lineranges` release from the fork's releases page. Without
the fork, Java is still formatted, just by the slower fallback described below.

### 4. This config

```sh
git clone https://github.com/Tylopilus/nvim ~/.config/nvim
ln -s ~/.config/nvim/extras/prettierrc.mjs ~/.prettierrc.mjs
mkdir -p ~/.local/bin && ln -s ~/.config/nvim/extras/prettier-changed ~/.local/bin/prettier-changed
```

- `extras/prettierrc.mjs`: prettier settings for everything under `~`; it
  loads the plugins from the global npm packages.
- `extras/prettier-changed`: `prettier-changed <file>...` formats only the
  lines changed since HEAD, for coding agents and the command line.

Start `nvim`: the plugins install from the lockfile, then Mason installs the
language servers and tools, and the treesitter parsers build. Restart once
everything is done.

### 5. Optional: Outrigger

Adds null analysis to jdtls. Without it jdtls runs directly.

```sh
git clone https://github.com/Tylopilus/outrigger ~/dev/projects/outrigger
cd ~/dev/projects/outrigger && mvn package
```

To analyse the implementations of AEM interfaces (`PageManager`, `Asset`, ...),
point it at a local AEM's bundles in `~/.config/outrigger/config.properties`:

```properties
implementations=~/dev/eplan/AEM/publish/crx-quickstart/launchpad/felix
```

## Formatting

- `<leader>f` formats only the lines changed since the last commit, a visual
  selection only the selected lines, `<leader>F` the whole file.
- Java: prettier formats exactly those lines through the fork's `lineRanges`.
- Everything else, and Java without the fork: the file is formatted in memory
  and only the formatting changes on the changed lines are applied. The result
  is only applied if formatting it fully gives the same text as formatting the
  original, so a partial format can't change the code.

## Updating

- Neovim: `brew upgrade neovim`
- Plugins, Mason packages, treesitter parsers: `:UpdateAll` in Neovim. Review
  the plugin changes in the tab it opens, `:write` to apply them, `:restart`.
- Commit `nvim-pack-lock.json` afterwards; to go back, restore it and run
  `:lua vim.pack.update(nil, { target = "lockfile" })`.

Downloads can fail behind the corporate VPN, which intercepts HTTPS; update off
the VPN.
