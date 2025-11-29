-- ============================================================================
-- Transparent Background Plugin
-- Provides commands to toggle background transparency in Neovim
-- ============================================================================

local M = {}

-- Highlight groups that should be affected by transparency
local TRANSPARENT_GROUPS = {
  -- Core
  "Normal", "NormalNC", "SignColumn", "EndOfBuffer",
  "LineNr", "CursorLineNr", "NonText",
  -- Syntax
  "Comment", "Constant", "Special", "Identifier", "Statement",
  "PreProc", "Type", "Underlined", "Todo", "String", "Function",
  "Conditional", "Repeat", "Operator", "Structure",
  -- Plugins
  "NeoTreeNormal", "NeoTreeNormalNC",
}

-- ============================================================================
-- Helper Functions
-- ============================================================================

--- Get the current background color from Normal highlight group
--- @return string Background color or "NONE" if not set
local function get_background_color()
  local bg = vim.fn.synIDattr(vim.fn.hlID("Normal"), "bg")
  return (bg ~= "" and bg) or "NONE"
end

--- Set background color for all transparent groups
--- @param color string Background color value
local function set_background(color)
  for _, group in ipairs(TRANSPARENT_GROUPS) do
    vim.cmd.highlight(group .. " guibg=" .. color)
  end
end

--- Save current background color if valid
local function save_background()
  local bg = get_background_color()
  if bg ~= "NONE" then
    vim.g.bg_color = bg
  end
end

-- ============================================================================
-- Public Functions
-- ============================================================================

--- Setup the transparent plugin with options
--- @param opts table|nil Configuration options
function M.setup(opts)
  opts = opts or {}

  if opts.auto_enable then
    vim.api.nvim_create_autocmd("VimEnter", {
      once = true,
      callback = function()
        vim.schedule(function()
          save_background()
          M.enable()
        end)
      end,
    })
  end
end

--- Enable transparent background
function M.enable()
  save_background()
  set_background("NONE")
  vim.g.bg_transparent = true
end

--- Disable transparent background and restore original colors
function M.disable()
  local bg_color = vim.g.bg_color

  if not bg_color or bg_color == "NONE" then
    if vim.g.colors_name then
      vim.cmd.colorscheme(vim.g.colors_name)
    end
    bg_color = get_background_color()
  end

  set_background(bg_color)
  vim.g.bg_transparent = false
end

--- Toggle transparent background
function M.toggle()
  if vim.g.bg_transparent then
    M.disable()
  else
    M.enable()
  end
end

-- ============================================================================
-- Initialization
-- ============================================================================

vim.g.bg_color = get_background_color()
vim.g.bg_transparent = false

vim.api.nvim_create_user_command("TransparentEnable", M.enable, {
  desc = "Enable transparent background",
})
vim.api.nvim_create_user_command("TransparentDisable", M.disable, {
  desc = "Disable transparent background and restore original colors",
})
vim.api.nvim_create_user_command("TransparentToggle", M.toggle, {
  desc = "Toggle transparent background",
})
vim.keymap.set("n", "<leader>t", M.toggle, {
  desc = "Toggle transparent background",
})

return M
