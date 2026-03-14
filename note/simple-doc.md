# Neovim Config — Keymap Reference

> **Leader key:** `Space`  
> **Local leader:** `Space` (same)  
> Config repo: [Imngzx/nvim-config-rice-.ver-](https://github.com/Imngzx/nvim-config-rice-.ver-)

---

## Table of Contents

- [Notation](#notation)
- [Core — File & Session](#core--file--session)
- [Navigation — Windows & Buffers](#navigation--windows--buffers)
- [Editing](#editing)
- [Search & Picker (Snacks)](#search--picker-snacks)
- [File Explorer (Snacks)](#file-explorer-snacks)
- [LSP](#lsp)
- [Diagnostics](#diagnostics)
- [Git](#git)
- [Code Runner](#code-runner)
- [Debugger (DAP)](#debugger-dap)
- [AI (CodeCompanion)](#ai-codecompanion)
- [UI Toggles](#ui-toggles)
- [Winbar (Dropbar)](#winbar-dropbar)
- [Word Jump (Flash-like)](#word-jump-flash-like)
- [Surround](#surround)
- [TODO](#todo)
- [CSV reading assistance](#csv-tsv-csvview) 
- [Plugin Management](#plugin-management)
- [Profiler](#profiler)

---

## Notation

| Symbol | Meaning |
|--------|---------|
| `<leader>` | `Space` |
| `<localleader>` | `Space` |
| `n` | Normal mode |
| `i` | Insert mode |
| `v` / `x` | Visual / Visual-block mode |
| `t` | Terminal mode |
| `o` | Operator-pending mode |

---

## Core — File & Session

| Key | Mode | Action |
|-----|------|--------|
| `<leader>w` | n | Save file |
| `<C-s>` | n, i, x, s | Save file and return to normal |
| `<leader>wq` | n | Save and quit |
| `<leader>qq` | n | Quit all |

---

## Navigation — Windows & Buffers

### Buffers

| Key | Mode | Action |
|-----|------|--------|
| `<S-h>` | n | Previous buffer |
| `<S-l>` | n | Next buffer |
| `<leader>bn` | n | New empty file |
| `<leader>bd` | n |  Wipeout current buffer (completely free memory)|
| `<leader>bo` | n | Wipeout all other buffers |
| `<leader>br` | n | Rename current file |
| `q` | n | Close special buffers (Help, Quickfix, LSP Info, etc.) |

### Windows / Splits

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ps` | n | Split window below |
| `<leader>pv` | n | Split window right |
| `<leader>pd` | n | Close current window |
| `<C-h>` | n | Move to left window |
| `<C-j>` | n | Move to bottom window |
| `<C-k>` | n | Move to top window |
| `<C-l>` | n | Move to right window |
| `<BS>` | n | Move to left window (terminal `<C-h>` fix) |
| `<C-Left>` | n | Decrease window width |
| `<C-Right>` | n | Increase window width |
| `<C-Up>` | n | Increase window height |
| `<C-Down>` | n | Decrease window height |

### Terminal

| Key | Mode | Action |
|-----|------|--------|
| `<leader>pt` | n | Open terminal (horizontal split) |
| `<C-/>` | n | Toggle floating terminal (Snacks) |
| `<Esc><Esc>` | t | Exit terminal mode |

---

## Editing

### Motion

| Key | Mode | Action |
|-----|------|--------|
| `j` | n, v | Move down by visual line (wrap-aware) |
| `k` | n, v | Move up by visual line (wrap-aware) |
| `n` | n, x, o | Next search result (always forward) |
| `N` | n, x, o | Prev search result (always backward) |
| `<Esc>` | n, i, s | Clear search highlight + escape |

### Indenting

| Key | Mode | Action |
|-----|------|--------|
| `>` | x | Indent selection (stays selected) |
| `<` | x | Unindent selection (stays selected) |

### Moving Lines

| Key | Mode | Action |
|-----|------|--------|
| `<A-k>` | n, i, v | Move line(s) up |
| `<A-j>` | n, i, v | Move line(s) down |

### Comments

| Key | Mode | Action |
|-----|------|--------|
| `gco` | n | Add commented line below cursor |
| `gcO` | n | Add commented line above cursor |
| `gcc` | n | Toggle comment on line (built-in) |
| `gc` | x | Toggle comment on selection (built-in) |

### Spelling

| Key | Mode | Action |
|-----|------|--------|
| `<leader>cs` | n | Show spelling suggestions (`z=`) |
| `<leader>us` | n | Toggle spell checking |

### Reference Jumping

| Key | Mode | Action |
|-----|------|--------|
| `]]` | n, t | Jump to next reference of word under cursor |
| `[[` | n, t | Jump to previous reference of word under cursor |

---

## Search & Picker (Snacks)

> All pickers use your custom layout: wide horizontal on large screens, vertical on narrow. Press `?` inside a picker to see its own keybindings.

### Finding Files

| Key | Mode | Action |
|-----|------|--------|
| `<leader><space>` | n | Smart find (git files + recent) |
| `<leader>fb` | n | List open buffers |
| `<leader>fc` | n | Find Neovim Config files (from anywhere)|
| `<leader>fC` | n | Grep inside Neovim Config (from anywhere) |
| `<leader>ff` | n | Find git-tracked files |
| `<leader>fp` | n | Browse projects |

### Grep / Search in Files

| Key | Mode | Action |
|-----|------|--------|
| `<leader>/` | n | Live grep across project |
| `<leader>fl` | n | Search lines in current buffer |
| `<leader>fB` | n | Grep across all open buffers |
| `<leader>fw` | n, x | Grep word under cursor or selection |

### Misc Finders

| Key | Mode | Action |
|-----|------|--------|
| `<leader>fr` | n | Browse registers |
| `<leader>sc` | n | Command history |
| `<leader>s/` | n | Search history |
| `<leader>sn` | n | Notification history |
| `<leader>sa` | n | Browse autocmds |
| `<leader>sC` | n | Browse commands |
| `<leader>sh` | n | Help pages |
| `<leader>sH` | n | Highlight groups |
| `<leader>si` | n | Icons browser |
| `<leader>sk` | n | Keymaps |
| `<leader>sm` | n | Marks |
| `<leader>su` | n | Undo history (visual tree) |
| `<leader>st` | n | Search TODOs |
| `<leader>?` | n | Buffer-local keymaps (which-key) |

---

## File Explorer (Snacks)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>e` | n | Toggle file explorer (left sidebar) |

**Inside the explorer:**

| Key | Action |
|-----|--------|
| `<Enter>` | Open file / expand directory |
| `a` | Create new file or directory (end with `/` for dir) |
| `r` | Rename |
| `d` | Delete |
| `y` | Copy |
| `x` | Cut |
| `p` | Paste |
| `P` | Toggle preview |
| `H` | Toggle hidden files |
| `q` | Close explorer |

---

## LSP

> These keymaps are active when an LSP server is attached to the buffer.

### Navigation

| Key | Mode | Action |
|-----|------|--------|
| `gd` | n | Go to definition (Snacks picker) |
| `gD` | n | Go to declaration (Snacks picker) |
| `gr` | n | Find all references (Snacks picker) |
| `gI` | n | Go to implementation (Snacks picker) |
| `gy` | n | Go to type definition (Snacks picker) |
| `gi` | n | Go to implementation (native LSP) |
| `gt` | n | Type definition (native LSP) |

### Actions

| Key | Mode | Action |
|-----|------|--------|
| `K` | n | Hover documentation |
| `<leader>ch` | n | Hover documentation |
| `<leader>cr` | n | Rename symbol |
| `<leader>ca` | n, x | Code action |
| `<C-k>` | i | Signature help |
| `<leader>cf` | n | Format file (conform.nvim) |
| `<leader>co` | n | LSP symbols in file (Snacks picker) |
| `<leader>cv` | n | Select Python virtual environment |
| `<leader>pl` | n | LSP info / health check |
| `<leader>uh` | n | Toggle inlay hints |

---

## Diagnostics

| Key | Mode | Action |
|-----|------|--------|
| `<leader>cl` | n | Show line diagnostics (float) |
| `<leader>cd` | n | Buffer diagnostics (Snacks picker) |
| `<leader>cD` | n | All diagnostics (Snacks picker) |
| `]d` | n | Next diagnostic |
| `[d` | n | Prev diagnostic |
| `]e` | n | Next error |
| `[e` | n | Prev error |
| `]w` | n | Next warning |
| `[w` | n | Prev warning |

---

## Git

| Key | Mode | Action |
|-----|------|--------|
| `<leader>gg` | n | Open Lazygit |
| `<leader>gB` | n, v | Open file in browser (git browse) |
| `<leader>gb` | n | Browse branches |
| `<leader>gl` | n | Git log |
| `<leader>gs` | n | Git status |
| `<leader>gS` | n | Git stash |
| `<leader>gf` | n | Git diff hunks (Snacks picker) |
| `<leader>go` | n | Toggle inline diff overlay (mini.diff) |
| `<leader>gh` | n, x | Apply hunk(s) |
| `<leader>gH` | n, x | Reset hunk(s) |
| `]h` | n | Next hunk |
| `[h` | n | Prev hunk |
| `]H` | n | Last hunk |
| `[H` | n | First hunk |

---

## Code Runner

> Supports: C, C++, Python, Java, Rust, TypeScript, Zig.  
> Output appears in a floating window by default.

| Key | Mode | Action |
|-----|------|--------|
| `<F5>` | n | Save and run (smart: project or file) |
| `<C-F5>` | n | Save and run current file only |
| `<S-F5>` | n | Stop / close runner |
| `<leader>rc` | n | Save and run (smart) |
| `<leader>rf` | n | Save and run current file |
| `<leader>rp` | n | Run project |
| `<leader>rx` | n | Close runner window |

> **C/C++ build mode** is configurable at the top of `lua/plugins/coderunner.lua`:  
> `C_BUILD_TYPE = 1` → GCC Release · `C_BUILD_TYPE = 2` → Clang Debug + sanitizers

---

## Debugger (DAP)

> Requires Mason tools: `codelldb` (C/C++/Rust/Zig), `debugpy` (Python).

### UI

| Key | Mode | Action |
|-----|------|--------|
| `<leader>du` | n | Toggle DAP View (variables, stack, etc.) |

### Breakpoints

| Key | Mode | Action |
|-----|------|--------|
| `<leader>db` | n | Toggle breakpoint |
| `<leader>dB` | n | Set conditional breakpoint |

### Execution

| Key | Mode | Action |
|-----|------|--------|
| `<leader>dc` | n | Continue / start |
| `<leader>dC` | n | Run to cursor |
| `<leader>di` | n | Step into |
| `<leader>dO` | n | Step over |
| `<leader>do` | n | Step out |
| `<leader>dl` | n | Re-run last session |
| `<leader>dt` | n | Terminate session |
| `<leader>dp` | n | Pause |

### Inspection

| Key | Mode | Action |
|-----|------|--------|
| `<leader>dr` | n | Toggle REPL |
| `<leader>dw` | n | Hover widget (inspect value) |
| `<leader>ds` | n | Show session info |
| `<leader>dg` | n | Jump to line (no execute) |
| `<leader>dj` / `<leader>dk` | n | Move down/up in call stack |

### Python only

| Key | Mode | Action |
|-----|------|--------|
| `<localleader>pdt` | n | Debug test method |
| `<localleader>pdc` | n | Debug test class |

---

## AI (CodeCompanion)

> Default adapter: **Gemini Flash**. Press `ga` inside the chat buffer to switch adapters (Gemini / Claude / Codex).

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ai` | n | Toggle AI chat panel |
| `<leader>ae` | n, v | Inline AI edit (selection or prompt) |
| `<leader>ac` | n, v | AI action palette |

---

## UI Toggles

| Key | Mode | Action |
|-----|------|--------|
| `<leader>us` | n | Toggle spell check |
| `<leader>uw` | n | Toggle line wrap |
| `<leader>uL` | n | Toggle relative line numbers |
| `<leader>ul` | n | Toggle line numbers |
| `<leader>ub` | n | Toggle dark / light background |
| `<leader>uc` | n | Toggle conceal level |
| `<leader>ut` | n | Toggle transparency |
| `<leader>uT` | n | Toggle Treesitter highlight |
| `<leader>uh` | n | Toggle inlay hints |
| `<leader>ug` | n | Toggle indent guides |
| `<leader>ud` | n | Toggle diagnostics |
| `<leader>uD` | n | Toggle dim (focus mode) |
| `<leader>um` | n | Toggle Markdown rendering |
| `<leader>uz` | n | Toggle Zen mode |
| `<leader>uZ` | n | Toggle zoom (maximize window) |
| `<leader>bs` | n | Toggle scratch buffer |

---

## Winbar (Dropbar)

> Shows the breadcrumb path at the top of each window (function → class → file).

| Key | Mode | Action |
|-----|------|--------|
| `<leader>;` | n | Pick a symbol in the winbar interactively |
| `[;` | n | Jump to start of current context |
| `];` | n | Select next context level |

---

## Word Jump (Flash-like)

> Pluginless reimplementation of `folke/flash.nvim`.

| Key | Mode | Action |
|-----|------|--------|
| `f` | n | Activate word jump — type label letters to teleport |

---

## Surround

> Pluginless reimplementation. Works on any text object.

| Key | Mode | Action |
|-----|------|--------|
| `sa{motion}{char}` | n | Add surround around motion |
| `sd{char}` | n | Delete surrounding char |
| `sr{old}{new}` | n | Replace surrounding char |
| `sa` | x | Add surround around selection |

---

## TODO

> Highlights `TODO`, `FIXME`, `HACK`, `NOTE`, `BUG`, `PERF` comments.

| Key | Mode | Action |
|-----|------|--------|
| `<leader>st` | n | Search all TODOs in project |

---

## CSV / TSV (CsvView)

> Active only in `.csv` and `.tsv` files.

| Key | Mode | Action |
|-----|------|--------|
| `if` / `af` | o, x | Inner / outer field textobject |
| `<Tab>` | n, v | Jump to next field |
| `<S-Tab>` | n, v | Jump to previous field |
| `<Enter>` | n, v | Jump to next row |
| `<S-Enter>` | n, v | Jump to previous row |

---

## Plugin Management

| Key | Mode | Action |
|-----|------|--------|
| `<leader>pm` | n | Open Mason (install/update LSP tools) |
| `<leader>pu` | n | Update all plugins (`vim.pack.update`) |
| `<leader>pN` | n | Open Neovim news (`:h news.txt`) |

---

## Profiler

> Only available when launched with `PROF=1 nvim`.

| Key | Mode | Action |
|-----|------|--------|
| `<leader>spp` | n | Toggle profiler recording |
| `<leader>sps` | n | Open profiler scratch buffer |

---

## Treesitter Context

| Key | Mode | Action |
|-----|------|--------|
| `[c` | n | Jump up to the enclosing context (function/class header) |

---

*Last updated based on commit pushed 2026-03-14.*
