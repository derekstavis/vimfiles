# Neovim dotfiles

A Lua configuration for Neovim 0.12+, with a docked file tree, project search,
native LSP, completion, formatting, Git tools, debugging, and AI completion.
The interface uses Gruvbox dark with hard contrast and a per-window statusline.

## Getting started

Install Neovim 0.12+, Git, ripgrep, Node.js 20+ with npm, and a Nerd Font.
Language-tool installation also needs Python 3 with venv and Go.
Parser installation needs a C compiler and the
`tree-sitter` CLI 0.26.1+.

```sh
git clone https://github.com/derekstavis/vimfiles.git ~/.config/nvim
nvim
```

Plugins install automatically through `vim.pack`. Install the configured language
tools, CodeLLDB debugger, and syntax parsers, wait for installation to finish,
then restart Neovim:

```vim
:InstallTools
:InstallParsers
```

Start Neovim from your project's root directory so file search and project tools
use that working directory. Normal interactive startup opens a 14-line terminal
at the bottom and leaves focus in the editor. Terminals use fish when available,
with `sh` as the fallback.

The leader key is **`,`** and the local leader is **`'`**. Shortcuts below are
for Normal mode unless a section specifies otherwise.

## Find files and navigate code

| Shortcut | Action |
| --- | --- |
| Ctrl-P | Find project files, including hidden files |
| Ctrl-F | Search text across the project |
| Ctrl-B | Switch between open buffers |
| `,p` | Resume the last search picker |
| `,1` | Toggle the file tree |
| `,2` | Toggle the symbol outline sidebar |
| `,o` / `,s` | Search document / workspace symbols |
| `gd` / `gt` / `gi` | Jump to definition / type definition / implementation |
| `gr` | Find references |
| `K` | Show documentation for the symbol under the cursor |
| `,←` / `,→` | Go backward / forward through visited files |

### File tree and previews

The tree is docked on the left and spans the editing area's full height.
Opening a file keeps the tree visible. Previews appear only for files and follow the selection in a
borderless window beside it, with a filename header and a lighter Gruvbox
background. The preview fills the top row of adjacent editor splits, combining
their widths while leaving terminal panels and lower split rows visible.
Rename prompts open just below the selected entry; press Enter to confirm or Escape to cancel.

These shortcuts apply **inside the tree**:

| Shortcut | Action |
| --- | --- |
| `l` / `h` | Expand a directory or open a file / collapse or go to parent |
| Enter, `e`, `o` | Open a file or toggle a directory |
| Backspace | Collapse or go to parent |
| `es` / `ev` / `et` | Open in a horizontal split / vertical split / tab |
| `P` | Toggle automatic previews |
| Tab | Open or focus the preview; press again inside it to return to the tree |
| Escape | Dismiss previews |
| Ctrl-F / Ctrl-B | Scroll the preview down / up |
| `a` / `r` | Create / rename; append `/` when creating a directory |
| `yy` / `dd` / `p` | Copy / cut / paste files |
| `df` | Delete with confirmation |
| `yp` / `yn` | Copy the absolute path / filename |
| `zh` | Toggle hidden files |
| `gl` / `gh` | Expand / collapse the tree recursively |
| `?` / `q` | Show help / close the tree |

## Diagnose, refactor, and format

Native LSP provides diagnostics, navigation, rename, code actions, inlay hints,
and code lenses when supported by the language server.

| Shortcut | Action |
| --- | --- |
| `,[` / `,]` | Previous / next diagnostic |
| `,wtf` | Show diagnostic details at the cursor |
| `,d` | Search all diagnostics |
| `,rn` | Rename the symbol under the cursor |
| `,ca` | Choose a code action |
| `,vca` | Request code actions for a Visual selection |
| `,qf` | Apply a quick fix, or choose among available fixes |
| `,f` | Format the buffer, or the selection in Visual mode |
| `,pp` / `:Format` | Format the buffer; `:Format` also accepts a line range |

Formatting runs on save for JavaScript/TypeScript (including JSX/TSX), CSS,
Markdown, Rust, Go, and Terraform. Web files use Biome when a `biome.json` or
`biome.jsonc` is present, otherwise Prettier. Go uses goimports/gofmt, Terraform
uses `terraform fmt`, and LSP formatting supplies a fallback. Python uses Black
when formatting manually. HTML, JSON, and YAML also support manual formatting.

Use `:Mason` (or `,e`) to manage language tools. The configured servers cover
JavaScript/TypeScript, Rust, Python, Lua, Go, HTML, CSS, JSON, YAML, TOML, Markdown,
Haskell, ESLint, and Biome. Restart after installing a server so it is enabled.
Haskell requires `haskell-language-server-wrapper` on PATH; Terraform formatting
requires `terraform`. Install those separately.

For troubleshooting, use `:checkhealth vim.lsp` to inspect LSP setup and
`:ConformInfo` to inspect available formatters.

## Complete and edit

In **Insert mode**, completion appears automatically. Tab selects the next item
or triggers completion after text; Shift-Tab selects the previous item. Enter
accepts a selected item, and Ctrl-Space triggers completion explicitly.

Type a snippet prefix, then press Ctrl-J to expand it. Ctrl-L and Ctrl-H move
between snippet fields. Custom snippets live in [snippets/](snippets/), including
`log` for Java/JavaScript and `setTimeout` for JavaScript.

| Shortcut | Action |
| --- | --- |
| `gcc` / Visual `gc` | Toggle comments on a line / selection |
| `ysiw)` | Surround the word with parentheses |
| `cs)]` / `ds]` | Change parentheses to brackets / delete surrounding brackets |
| Visual `S` | Add a surrounding pair to a selection |
| `gS` / `gJ` | Split / join bracketed arguments |
| Alt-Up / Alt-Down | Add multiple cursors above / below |
| `p` / `P` | Paste after / before the cursor |
| Enter / Backspace after pasting | Replace the last paste with an older / newer yank |
| Space | Toggle a fold |
| `zO` / Ctrl-Space | Open / close all folds |
| `:StripWhitespace` | Trim trailing whitespace |
| `:BD` | Close a buffer while keeping its split; `:BD!` discards changes |

Yank cycling uses history from the current Neovim session. `:Fold` enables
LSP-based folding for the current window.

## Review and commit changes

Open `:Git` for the repository status view. Use `s` to stage the file or hunk
under the cursor and `u` to unstage it, then `:Git commit` to write a commit.
Git subcommands are available through `:Git`, such as `:Git diff`.

Use `:DiffviewOpen` for a diff review tab, `:DiffviewFileHistory %` for the current
file's history, and `:DiffviewClose` to close the review.

`,gh` opens the current file or Visual selection on GitHub. `,gb` opens blame,
and `,go` opens the repository page.

## Run and debug

Ctrl-arrows move between editor splits and terminals. Press `i` in a terminal
buffer to type into the shell. Shift-arrows move a split boundary by eight cells;
a numeric prefix changes the amount.

Tiny-term groups shells into tabs along the bottom of each terminal panel,
using the same Gruvbox colors and separators as the editor statusline. Labels
show a shell icon and the reported directory name, falling back to the known
program name, then the terminal title. Fish reports directory changes
automatically; other shells can report them with OSC 7. Click a tab to select
it or its **×** to close that shell. Press Escape twice to enter Normal mode,
then use Ctrl-] / Ctrl-[ to switch terminals or `q` to hide the panel. Hiding keeps
shells running; `,3` restores them. `,sh` adds a new terminal tab to the panel.
Adding tabs preserves the panel height and file tree width; hiding and restoring
the panel also keeps your chosen height.
Resizing preserves your scrollback position: the top stays fixed at the start,
the bottom stays fixed at the latest output, and positions in between stay centered.

| Shortcut | Action |
| --- | --- |
| `,sh` | New terminal tab in the bottom panel |
| `,3` | Toggle the bottom terminal panel (or the focused terminal panel) |
| Ctrl-] / Ctrl-[ | Next / previous terminal in the panel (terminal Normal mode) |
| `,vsh` / `,tsh` | New shell beside the current split / in a Neovim tab page |
| `,fs` | Toggle full-screen focus on the current buffer |
| `,ww` | Mark a window, then press in another window to swap their buffers |
| `,tn` / `,th` / `,tl` | New / previous / next tab |
| `:Clear` | Clear terminal scrollback |
| `,bp` | Toggle a breakpoint |
| `,rp` / `,kp` | Start a new debug session / disconnect |
| Ctrl-[ / Ctrl-{ | Step over / into (editor buffers) |
| Ctrl-] / Ctrl-} | Step out / continue (editor buffers) |

Configure `require('dap').adapters` and `require('dap').configurations` for your
project before starting a debug session. The debug UI opens on launch/attach and
closes when the session ends. If your terminal sends Escape for Ctrl-[, use
`:DapStepOver` or customize the debugger shortcuts.

Save a workspace explicitly with `:SaveSession name`. `:LoadSession` selects a
saved workspace; `:DeleteSession` removes one.

## AI completion

Authenticate inline completion with `:Copilot auth`. Suggestions appear as you
type; **Ctrl-Enter** accepts one.

## Customize and maintain

Project `.editorconfig` files control indentation and related settings.
Put project-specific Lua settings, LSP overrides, or debugger setup in
`.nvim.lua`; review and trust the file when Neovim prompts before loading it.

`,ev` opens `init.lua`, and `,sv` reloads the configuration. The main modules are:

| Location | Purpose |
| --- | --- |
| [options.lua](lua/config/options.lua), [autocmds.lua](lua/config/autocmds.lua) | Editor defaults and automatic behavior |
| [keymaps.lua](lua/config/keymaps.lua) | Navigation, windows, terminals, and commands |
| [languages.lua](lua/config/languages.lua) | LSP, completion keys, and formatting |
| [explorer.lua](lua/config/explorer.lua), [explorer_preview.lua](lua/config/explorer_preview.lua) | Tree layout, preview sizing, and file operations |
| [terminal.lua](lua/config/terminal.lua), [terminal_tabs.lua](lua/config/terminal_tabs.lua) | Terminal panels, tab bars, and shell lifecycle |
| [terminal_view.lua](lua/config/terminal_view.lua) | Scrollback positioning during terminal resize |
| [mini.lua](lua/config/mini.lua) | Editing tools, snippets, and sessions |
| [integrations.lua](lua/config/integrations.lua) | Theme, search, statusline, debugging, and AI completion |
| [plugins.lua](lua/config/plugins.lua), [treesitter.lua](lua/config/treesitter.lua) | Plugin management and parsers |

Run `:PackUpdate`, review the update buffer, and use `:write` to apply or `:quit`
to discard. Restart afterward and commit `nvim-pack-lock.json` with intentional
plugin updates. Use `:Mason` to update language tools and `:UpdateParsers` to
update supported installed parsers. Custom parsers such as UVML are managed
separately.

Run the configuration checks from this repository after installing tools and
parsers. The UI check requires an interactive terminal.

```sh
nvim --headless --cmd 'let g:loaded_wakatime = 1' -c 'luafile tests/smoke.lua'
nvim --headless --cmd 'let g:loaded_wakatime = 1' -c 'luafile tests/languages.lua'
nvim --cmd 'let g:loaded_wakatime = 1' -c 'autocmd VimEnter * ++once luafile tests/ui.lua'
```
