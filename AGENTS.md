# Neovim Configuration Project

## Project Structure

```
lua/                 # Core configuration directory
├── custom/           # Custom module implementations (no plugins)
│   ├── coderunner.lua  # Build/run integration
│   ├── zettel.lua      # Note-taking system
│   ├── transparent.lua   # Background transparency management
│   ├── session.lua      # Workspace persistence
│   ├── startup.lua     # Optimized startup logic
│   ├── workspace.lua    # Project navigation
│   ├── cheatsheet.lua    # Quick reference system
│   ├── repl.lua         # Interactive read-eval-print loop
│   ├── git-blame.lua    # Git integration
│   ├── incline.lua      # LSP client management
│   ├── color-list.lua   # Color scheme tools
│   ├── git.lua          # Git workflow helpers
│   ├── language-switcher.lua # Language toggling
│   ├── pairs.lua        # Utility functions
│   ├── sudo.lua         # Elevated privilege commands
│   ├── todo.lua         # Code annotation search
│   ├── ui2.lua          # UI enhancements
│   ├── word-jump.lua    # Navigation utilities
│   └── yazi.lua        # Theme management
└── plugins/           # Plugin configurations

note/                  # Project knowledge base
└── knowledge/         # Auto-generated module documentation

```

## Code Style Guidelines

### 1. Module Structure

```lua
local M = {}  -- Module container

-- Local utilities
local api = vim.api
local fn = vim.fn
local utils = require('libs.utils')

-- Configuration section
function M.setup()  -- Initialization logic
  -- ...
end

-- Core functionality
function M.core_function()  -- Feature implementation
  -- ...
end

return M  -- Expose module
```

### 2. Performance Optimization

- **Fast Path Pattern**:

  ```lua

if vim.loader then
  vim.loader.enable()  -- Bytecode caching
end

```
- **Power-aware Selection**:
  ```lua
if require('libs.power').is_ac() then
  -- Use feature-rich implementation
else
  -- Use lightweight alternative
end
```

### 3. Error Handling

```lua
local ok, mod = pcall(require, 'module.name')
if not ok then
  -- Fallback logic
end
```

### 4. UI Elements

- **Keymaps**:

  ```lua

vim.keymap.set('n', '<leader>rp', M.run_project, { desc = 'Run Project' })

```
- **Highlighting**:
  ```lua
vim.api.nvim_set_hl(0, 'CustomGroup', { fg = '#ff0000' })
```

### 5. Cross-Module Communication

```lua
-- Using shared namespaces
_G.MyGlobalState = _G.MyGlobalState or {}

-- Event-driven
vim.api.nvim_create_autocmd('VimLeavePre', {
  pattern = '*',
  callback = function() M.save() end
})

## Documentation Standards

### 1. Knowledge Base
- Each module in `lua/custom/` should have a corresponding
  `note/knowledge/<module>.md` file
- Documentation should include:
  - Module purpose
  - Core functions
  - Configuration options
  - Key mappings
  - Performance considerations

### 2. Code Comments
```lua
--queues the repaint of the floating window to avoid flickering
vim.schedule(20, function() self:repaint() end)
```

## Plugin Management

### 1. Disabled Built-ins

```lua
-- Disable unwanted built-in plugins
local disabled_built_ins = {'fzf', 'gzip', 'matchit'}
for _, plugin in ipairs(disabled_built_ins) do
  vim.g['loaded_'..plugin] = 1
end
```

### 2. Plugin Installation and Configuration

```lua
local resonance = require('resonance')

resonance.load({
  {
    src = "https://github.com/<author>/<plugin1_name>",

    dependencies = "https://github.com/<author>/<plugin2_name>",

    build = 'make', -- npm i or others based on plugin's docs
      
    cmd = {'cmd1', 'cmd2'},

    keys = {
      { 'n', '<leader>Tg', '<cmd>cmd1<CR>', { desc = 'Open something' } },
      { 'n', '<leader>TL', '<cmd>cmd2<CR>', { desc = 'Do something' } },
    },

    event = { "BufReadPre", "BufNewFile" },
    -- For VeryLazy, use: event = { "User", pattern = "VeryLazy" }
    config = function()

      local name = require('plugin1_name')

      name.setup({
      -- Config here...
      })

    end
  },
  
  { -- another plugin...},

  { -- another plugin...},
})
```

## Development Workflow

### 1. Exploration

- Use `snacks` for code navigation and analysis
- Leverage `lsp` for language server integration

### 2. Implementation

- Follow **single-responsibility principle** for modules
- Use **답변 보도 `TextChanged` events for real-time features**

### 3. Verification

- Test with actual runtime execution (`:luafile`)
- Use `debug` tool for breakpoints

This document reflects the current codebase structure and establishes standards for maintaining and extending the configuration.
