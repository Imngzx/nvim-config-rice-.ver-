# transparent.lua Documentation

## Overview
Manages background transparency in Neovim with configurable groups and persistence.

## Configuration
- `exclude_groups`: List of UI groups to exclude from transparency
- `on_clear`: Configuration-specific clearing logic
- `cache_path`: Stores transparency state in `data/transparent_state` file

## Core Functions
- `M.enable()`: Enables background transparency
- `M.disable()`: Disables background transparency
- `M.toggle()`: Toggles transparency state
- `M.setup(opts)`: Initializes transparency with optional configuration
- `M.clear()`: Clears transparency for specified groups

## User Commands
- `:TransparentEnable` – Enable transparency
- `:TransparentDisable` – Disable transparency
- `:TransparentToggle` – Toggle transparency state

## Key Mappings
- `<leader>ut` – Toggle transparency

## Transparency Management
- Uses `vim.g.bg_transparent` to track state
- Persists state in cache file
- Handles different UI groups selectively

## Example Usage
```lua
-- Enable transparency
:TransparentEnable

-- Toggle transparency state
<leader>ut
```

This module provides a simple interface to manage background transparency in Neovim with support for configuration and persistence.