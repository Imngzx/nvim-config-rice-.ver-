--
-- https://github.com/nvim-telescope/telescope.nvim

local Util = require("util")
local icons = require("icons")

return {
  "nvim-telescope/telescope.nvim",
  -- commit = vim.fn.has("nvim-0.9.0") == 0 and "057ee0f8783" or nil,
  cmd = "Telescope",
  version = false, -- telescope did only one release, so use HEAD for now
  keys = {
    { "<leader>,", "<cmd>Telescope buffers<cr>",         desc = "Buffers" },
    { "<leader>/", Util.telescope("live_grep"),          desc = "Grep (root dir)" },
    { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
    {
      "<leader><space>",
      Util.telescope("files"),
      desc =
      "Find Files (root dir)"
    },
    -- find
    { "<leader>fb", "<cmd>Telescope buffers<cr>",                         desc = "Buffers" },
    {
      "<leader>ff",
      Util.telescope("files"),
      desc =
      "Find Files (root dir)"
    },
    { "<leader>fF", Util.telescope("files", { cwd = false }),             desc = "Files (cwd)" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>",                        desc = "Recent" },
    { "<leader>fR", Util.telescope("oldfiles", { cwd = vim.loop.cwd() }), desc = "Recent (cwd)" },
    { "<leader>fc", "<cmd>Telescope commands<cr>",                        desc = "Commands" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>",                       desc = "Help" },
    -- git
    { "<leader>gc", "<cmd>Telescope git_commits<CR>",                     desc = "Commits" },
    { "<leader>gs", "<cmd>Telescope git_status<CR>",                      desc = "Status" },
    -- search
    { "<leader>fd", "<cmd>Telescope diagnostics bufnr=0<cr>",             desc = "Document diagnostics" },
    {
      "<leader>fD",
      "<cmd>Telescope diagnostics<cr>",
      desc =
      "Workspace diagnostics"
    },
    { "<leader>fg", Util.telescope("live_grep"),                                       desc = "Grep (root dir)" },
    { "<leader>fG", Util.telescope("live_grep", { cwd = false }),                      desc = "Grep (cwd)" },
    { "<leader>fk", "<cmd>Telescope keymaps<cr>",                                      desc = "Key Maps" },
    -- { "<leader>sm", "<cmd>Telescope marks<cr>",                                        desc = "Jump to Mark" },
    -- { "<leader>so", "<cmd>Telescope vim_options<cr>",                                  desc = "Options" },
    -- { "<leader>sR", "<cmd>Telescope resume<cr>",                                       desc = "Resume" },
    { "<leader>fw", Util.telescope("grep_string", { word_match = "-w" }),              desc = "Word (root dir)" },
    { "<leader>fW", Util.telescope("grep_string", { cwd = false, word_match = "-w" }), desc = "Word (cwd)" },
    {
      "<leader>fw",
      Util.telescope("grep_string"),
      mode = "v",
      desc =
      "Selection (root dir)"
    },
    -- {
    --   "<leader>sW",
    --   Util.telescope("grep_string", { cwd = false }),
    --   mode = "v",
    --   desc =
    --   "Selection (cwd)"
    -- },
    -- {
    --   "<leader>uC",
    --   Util.telescope("colorscheme", { enable_preview = true }),
    --   desc =
    --   "Colorscheme with preview"
    -- },
    -- {
    --   "<leader>ss",
    --   Util.telescope("lsp_document_symbols", {
    --     symbols = {
    --       "Class",
    --       "Function",
    --       "Method",
    --       "Constructor",
    --       "Interface",
    --       "Module",
    --       "Struct",
    --       "Trait",
    --       "Field",
    --       "Property",
    --     },
    --   }),
    --   desc = "Goto Symbol",
    -- },
    -- {
    --   "<leader>sS",
    --   Util.telescope("lsp_dynamic_workspace_symbols", {
    --     symbols = {
    --       "Class",
    --       "Function",
    --       "Method",
    --       "Constructor",
    --       "Interface",
    --       "Module",
    --       "Struct",
    --       "Trait",
    --       "Field",
    --       "Property",
    --     },
    --   }),
    --   desc = "Goto Symbol (Workspace)",
    -- },
  },
  opts = {
    defaults = {
      prompt_prefix = icons.arrows.ArrowClosed .. ' ',
      selection_caret = icons.arrows.CaretRight .. ' ',
      mappings = {
        i = {
          ["<c-t>"] = function(...)
            return require("trouble.providers.telescope").open_with_trouble(...)
          end,
          ["<a-t>"] = function(...)
            return require("trouble.providers.telescope").open_selected_with_trouble(...)
          end,
          ["<a-i>"] = function()
            local action_state = require("telescope.actions.state")
            local line = action_state.get_current_line()
            Util.telescope("find_files", { no_ignore = true, default_text = line })()
          end,
          ["<a-h>"] = function()
            local action_state = require("telescope.actions.state")
            local line = action_state.get_current_line()
            Util.telescope("find_files", { hidden = true, default_text = line })()
          end,
          ["<C-Down>"] = function(...)
            return require("telescope.actions").cycle_history_next(...)
          end,
          ["<C-Up>"] = function(...)
            return require("telescope.actions").cycle_history_prev(...)
          end,
          ["<C-f>"] = function(...)
            return require("telescope.actions").preview_scrolling_down(...)
          end,
          ["<C-b>"] = function(...)
            return require("telescope.actions").preview_scrolling_up(...)
          end,
        },
        n = {
          ["q"] = function(...)
            return require("telescope.actions").close(...)
          end,
        },
      },
      layout_config = {
        horizontal = {
          height = 0.95,
          preview_cutoff = 95,
          prompt_position = "bottom",
          width = 0.95
        },
      }
    },
  },
}
