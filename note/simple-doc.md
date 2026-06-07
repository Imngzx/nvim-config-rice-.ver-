# Cameron's Neovim Config — Keymap Reference

> **Leader key:** `Space`  
> **Local leader:** `Space` (same)  
> Config repo: [Imngzx/nvim-config-rice-.ver-](https://github.com/Imngzx/nvim-config-rice-.ver-)
---

## Table of Contents

- [Core — File & Session](#core--file--session)
- [Navigation — Windows & Buffers](#navigation--windows--buffers)
- [Editing & Formatting](#editing--formatting)
- [Search & Picker (Snacks)](#search--picker-snacks)
- [File Explorer (Snacks)](#file-explorer-snacks)
- [LSP & Diagnostics](#lsp--diagnostics)
- [Git](#git)
- [Code Runner](#code-runner)
- [Debugger (DAP)](#debugger-dap)
- [AI (CodeCompanion)](#ai-codecompanion)
- [UI Toggles & Widgets](#ui-toggles--widgets)
- [Translation (Jisho)](#translation-jisho)
- [Flash & Word Jump](#flash--word-jump)
- [Surround](#surround)
- [CSV / TSV Assistance](#csv--tsv-csvview)
- [Plugin Management](#plugin-management)
- [Profiler](#profiler)
- [Treesitter Context](#treesitter-context)

---

## Core — File & Session

| Key | Mode | Action |
|-----|------|--------|
| `<leader>w` | n | Save file (Sudo write automatically if needed) |
| `<leader>wq` | n | Save and quit |
| `<leader>qq` | n | Quit all |
| `<leader>qr` | n | Restart Neovim |
| `<leader>?` | n | Show buffer-local keymaps (Which-Key) |

> **Session Management:** Sessions are automatically saved on exit per Git-branch/Directory.
> To manually restore, open Dashboard (`<leader>H`) and press `s`, or type `:RestoreSession`, `:RestoreLastSession`. Type `:StopSession` to disable saving for the current instance.

---

## Navigation — Windows & Buffers

### Buffers

| Key | Mode | Action |
|-----|------|--------|
| `<S-h>` | n | Previous buffer |
| `<S-l>` | n | Next buffer |
| `<leader>bn` | n | New empty buffer |
| `<leader>bd` | n | Wipeout current buffer (Clear memory) |
| `<leader>bo` | n | Wipeout all other buffers |
| `<leader>br` | n | Rename current file |
| `<leader>tab n` | n | New workspace |
| `<leader>tab r` | n | Rename workspace |
| `<leader>tab d` | n | Close workspace |
| `gt` or `]t` | n | Goto next workspace |
| `gT` or `[t` | n | Goto previous workspace |
| `q` | n | Close special buffers (Help, Quickfix, LSP Info, etc.) |

### Windows / Splits

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ps` | n | Split window below (Horizontal) |
| `<leader>pv` | n | Split window right (Vertical) |
| `<leader>pd` | n | Close current window |
| `<C-h>`/`<C-j>`/`<C-k>`/`<C-l>` | n | Move left / down / up / right |
| `<C-Left>`/`<C-Right>` | n | Decrease / Increase window width |
| `<C-Down>`/`<C-Up>` | n | Decrease / Increase window height |

### Terminal

| Key | Mode | Action |
|-----|------|--------|
| `<leader>pt` | n | Open smart terminal (Bottom split) |
| `<leader>pT` | n | Toggle floating terminal (Snacks) |
| `<Esc><Esc>` | t | Exit terminal mode to Normal mode |

---

## Editing & Formatting

| Key | Mode | Action |
|-----|------|--------|
| `j` / `k` | n, v | Move by visual line (wrap-aware) |
| `<A-j>` / `<A-k>`| n,i,v | Move current line(s) down/up |
| `>` / `<` | x | Indent / Unindent selection (stays selected) |
| `gco` / `gcO` | n | Add commented line below / above cursor |
| `gcc` / `gc` | n, x | Toggle comment (built-in) |
| `<leader>cs` | n | Spelling suggestions (`z=`) |
| `<leader>cf` | n | Format file (conform.nvim) |
| `n` / `N` | n,x,o | Next/Prev search result (centered) |
| `<Esc>` | n,i,s | Clear search highlight & escape |

---

## Search & Picker (Snacks)

### Find Files & Content

| Key | Mode | Action |
|-----|------|--------|
| `<leader><space>` | n | Smart find (git files + recent) |
| `<leader>ff` | n | Find git-tracked files |
| `<leader>fp` | n | Pick Projects |
| `<leader>/` | n | Live grep across project |
| `<leader>fl` | n | Search lines in current buffer |
| `<leader>fB` | n | Grep across all open buffers |
| `<leader>fw` | n, x | Grep word under cursor / selection |
| `<leader>fc` | n | Find Neovim Config files |
| `<leader>fC` | n | Grep inside Neovim Config |
| `<leader>fy` | n | Find file via **Yazi** (File Manager) |

### History & Meta

| Key | Mode | Action |
|-----|------|--------|
| `<leader>fb` | n | List open buffers |
| `<leader>fr` | n | Browse registers |
| `<leader>sc` | n | Command history |
| `<leader>s/` | n | Search history |
| `<leader>sn` | n | Notification history |
| `<leader>su` | n | Undo history (visual tree) |
| `<leader>st` | n | Search TODOs (`TODO`, `FIXME`, etc.) |
| `<leader>sk` | n | Keymaps |
| `<leader>sa` | n | List Autocmds |
| `<leader>sC` | n | List Neovim Commands |
| `<leader>sh` | n | Search Help Pages |
| `<leader>sH` | n | Search Highlights (Colors) |
| `<leader>si` | n | Search Icons (Mini.icons) |
| `<leader>sm` | n | Search Marks |

---

## File Explorer (Snacks)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>e` | n | Toggle File Explorer (Left sidebar) |
| `<leader>H` | n | Open Dashboard (Home) |
| `<leader>up` | n | Open color picker |

*Explorer Hotkeys: `Enter` (Open), `a` (New file/dir), `r` (Rename), `d` (Delete), `y/x/p` (Copy/Cut/Paste).*

---

## LSP & Diagnostics

### Navigation

| Key | Mode | Action |
|-----|------|--------|
| `gd` | n | Go to definition (Snacks picker) |
| `gD` | n | Go to declaration (Snacks picker) |
| `gr` | n | Find all references (Snacks picker) |
| `gI` | n | Go to implementation (Snacks picker) |
| `gy` | n | Go to type definition (Snacks picker) |
| `]]` / `[[` | n, t | Next / Prev reference of word under cursor |

### Actions & Diagnostics

| Key | Mode | Action |
|-----|------|--------|
| `K` or `<leader>ch` | n | Hover documentation |
| `<leader>cr` | n | Rename symbol |
| `<leader>ca` | n, x | Code action |
| `<C-k>` | i | Signature help |
| `<leader>co` | n | LSP symbols in file (Snacks picker) |
| `<leader>cv` | n | Select Python Virtual Environment |
| `<leader>cl` | n | Show line diagnostics (float) |
| `<leader>cd` | n | Buffer diagnostics (Snacks picker) |
| `<leader>cD` | n | Project diagnostics (Snacks picker) |
| `<leader>pl` | n | Check LSP Info (`:checkhealth vim.lsp`) |
| `]d` / `[d` | n | Next / Prev Diagnostic |
| `]e` / `[e` | n | Next / Prev Error |
| `]w` / `[w` | n | Next / Prev Warning |

---

## Git

| Key | Mode | Action |
|-----|------|--------|
| `<leader>gg` | n | Open Lazygit |
| `<leader>ga` | n | Toggle git stage (current file) |
| `<leader>gs` | n | Git status |
| `<leader>gl` | n | Git log |
| `<leader>gb` | n | Git blame line |
| `<leader>gL` | n, v | Git browse (Open in web browser) |
| `<leader>go` | n | Toggle inline diff overlay (mini.diff) |
| `<leader>gh` | n, x | Apply hunk(s) |
| `<leader>gH` | n, x | Reset hunk(s) |
| `]h` / `[h` | n | Next / Prev hunk |
| `[H` / `]H` | n | First / Last hunk (mini.diff) |
| `<leader>ub` | n | Toggle Git Blame inline text |
| `<leader>gB` | n | Git branches (Snacks picker) |
| `<leader>gS` | n | Git stash (Snacks picker) |
| `<leader>gD` | n | Git diff hunks (Snacks picker) |

---

## Code Runner

> Configuration via `RUNNER_MODE` and `BUILD_TYPE` in `lua/custom/coderunner.lua`.

| Key | Mode | Action |
|-----|------|--------|
| `<F5>` or `<leader>rc` | n | Save and Run Code (Smart) |
| `<C-F5>` or `<leader>rf`| n | Save and Run Current File |
| `<leader>rp` | n | Run Project |
| `<S-F5>` or `<leader>rx`| n | Stop / Close Runner |

---

## Debugger (DAP)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>du` | n | Toggle DAP View UI |
| `<leader>db` | n | Toggle Breakpoint |
| `<leader>dB` | n | Set Conditional Breakpoint |
| `<leader>dc` | n | Continue / Start |
| `<leader>dC` | n | Run to cursor |
| `<leader>di` / `dO` / `do` | n | Step Into / Over / Out |
| `<leader>dl` | n | Run Last (Repeat last debug session) |
| `<leader>dp` | n | Pause execution |
| `<leader>dj` / `<leader>dk` | n | Go Down / Up in call stack |
| `<leader>dg` | n | Go to line (No execute) |
| `<leader>dr` | n | Toggle REPL window |
| `<leader>ds` | n | View active debug Session |
| `<leader>dt` | n | Terminate Session |
| `<leader>dw` | n | Widgets hover (Evaluate variable under cursor) |
| `<localleader>pdt` | n | Debug Method (Python only) |
| `<localleader>pdc` | n | Debug Class (Python only) |

---

## AI (CodeCompanion)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ai` | n | Toggle AI Chat panel |
| `<leader>ae` | n, v | Inline AI Edit (Prompt / Selection) |
| `<leader>ac` | n, v | AI Action Palette |

*Press `ga` inside the chat buffer to switch adapters (Claude/Gemini/Codex).*

---

## UI Toggles & Widgets

### General Toggles

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ua` | n | Toggle Ascetic |
| `<leader>ut` | n | Toggle Transparency |
| `<leader>ub` | n | Toggle Background (Dark / Light) |
| `<leader>uz` | n | Toggle Zen Mode |
| `<leader>uZ` | n | Toggle Zoom (Maximize window) |
| `<leader>uw` | n | Toggle Line Wrap |
| `<leader>ul` | n | Toggle Line Numbers |
| `<leader>uL` | n | Toggle Relative Line Numbers |
| `<leader>ud` | n | Toggle Diagnostics (Show/Hide error lines) |
| `<leader>uc` | n | Toggle Conceal Level (Hide/Show markdown syntax) |
| `<leader>uT` | n | Toggle Treesitter Highlighting |
| `<leader>uh` | n | Toggle Inlay Hints (LSP) |
| `<leader>ug` | n | Toggle Indent Guides |
| `<leader>uD` | n | Toggle Dim (Focus mode for current scope) |
| `<leader>um` | n | Toggle Markdown Rendering |
| `<leader>bs` | n | Toggle Scratch Buffer |
| `<leader>uu` | n | Toggle undo-tree plugin |
| `<leader>us` | n | Toggle Spelling |

### Minimap

| Key | Mode | Action |
|-----|------|--------|
| `<leader>nm` | n | Toggle Minimap |
| `<leader>ns` | n | Focus Minimap |
| `<leader>no` | n | Open minimap explicitly |
| `<leader>nc` | n | Close minimap explicitly |
| `<leader>nr` | n | Refresh minimap manually |

### Winbar (Dropbar Breadcrumbs)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>;` | n | Pick a symbol in the winbar interactively |
| `[;` / `];` | n | Jump to start / Select next context |

---

## Translation (Jisho)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>tj` | n | Search word under cursor in Jisho |
| `<leader>tj` | v | Search selected text in Jisho |

----------

## Flash & Word Jump

| Key | Mode | Action |
|-----|------|--------|
| `f` | n,x,o | **DIY Word Jump:** Single-char teleport (Fastest blind jump) |
| `s` | n,x,o | **Flash:** Multi-char search & jump |
| `S` | n,x,o | **Flash Treesitter:** Select AST node (e.g., function, block) |
| `r` | o     | **Flash Remote:** Execute operator on a remote location |
| `R` | o,x   | **Flash Treesitter Search:** Remote AST node operation |
| `<C-s>` | c | **Toggle Flash:** Convert regular `/` search to Flash labels |

---

## Surround

| Key | Mode | Action |
|-----|------|--------|
| `sa{motion}{char}`| n | Add surround around motion |
| `sd{char}` | n | Delete surrounding char |
| `sr{old}{new}` | n | Replace surrounding char |
| `sa` | x | Add surround around selection |

---

## CSV / TSV (CsvView)

| Key | Mode | Action |
|-----|------|--------|
| `if` / `af` | o, x | Inner / Outer field textobject |
| `<Tab>` / `<S-Tab>` | n, v | Jump to next / prev field |
| `<Enter>` / `<S-Enter>`| n, v | Jump to next / prev row |

---

## Plugin Management

| Key | Mode | Action |
|-----|------|--------|
| `<leader>pm` | n | Open Mason (Install/Update LSP tools) |
| `<leader>pu` | n | Update all Neovim Plugins |
| `<leader>pN` | n | Open Neovim News (`:h news.txt`) |
| `<leader>pL` | n | Open **Resonance** UI (Panel) |

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

*Last updated based on commit pushed 2026-06-03.*
