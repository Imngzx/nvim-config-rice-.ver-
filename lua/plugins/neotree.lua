local M = {
  "nvim-neo-tree/neo-tree.nvim",
}

local folders = {
  Default = "󰉋",
  Open = "󰉖",
  Empty = "󱧴",
  EmptyOpen = "󱧵",
  Symlink = "󱧮",
  SymlinkOpen = "󱧯",
}

function M.opts()
  -- 配色修改
  vim.cmd("highlight clear NeoTreeGitIgnored")
  vim.cmd("highlight link NeoTreeGitIgnored Comment")
  vim.cmd("highlight clear NeoTreeGitUntracked")
  vim.cmd("highlight link NeoTreeGitUntracked NeoTreeGitAdded")
  vim.cmd("highlight clear NeoTreeNormal")
  vim.cmd("highlight link NeoTreeNormal Normal")

  -- vim.cmd("highlight NeoTreeTabInactive ctermbg=0 guibg=0 guifg=#767F72")
  vim.cmd("highlight clear NeoTreeTabInactive")
  vim.cmd("highlight link NeoTreeTabInactive Comment")
  -- vim.cmd("highlight NeoTreeTabSeparatorInactive ctermbg=0 guibg=0 guifg=#767F72")
  vim.cmd("highlight clear NeoTreeTabSeparatorInactive")
  vim.cmd("highlight link NeoTreeTabSeparatorInactive Comment")
  -- vim.cmd("highlight NeoTreeTabSeparatorActive ctermbg=0 guibg=0 guifg=0")
  vim.cmd("highlight clear NeoTreeTabSeparatorActive")
  vim.cmd("highlight link NeoTreeTabSeparatorActive Comment")

  return {
    -- Minify space used
    hide_root_node = true,
    retain_hidden_root_indent = false,

    auto_clean_after_session_restore = true,
    close_if_last_window = true, -- close Neo-tree if is the last window
    open_files_do_not_replace_types = { "terminal", "trouble", "qf" }, -- when opening files, do not use windows containing these filetypes or buftypes
    sort_case_insensitive = false, -- used when sorting files and directories in the tree

    -- Header
    sources = { "filesystem", "buffers", "git_status" },
    source_selector = {
      winbar = true,
      content_layout = "center",
      tabs_layout = "equal",
      sources = {
        { source = "filesystem", display_name = "File" },
        { source = "buffers", display_name = "Bufs" },
        { source = "git_status", display_name = "Git" },
      },
    },

    -- Window & mappings
    window = {
      width = 28,
      mappings = {
        ["<tab>"] = "toggle_node",
        ["<space>"] = { "toggle_preview", config = { use_float = true } },
        ["s"] = "open_split",
        ["v"] = "open_vsplit",
        ["Y"] = {
          function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            vim.fn.setreg("+", path, "c")
          end,
          desc = "Copy Path to Clipboard",
        },
        ["O"] = {
          function(state)
            require("lazy.util").open(state.tree:get_node().path, { system = true })
          end,
          desc = "Open with System Application",
        },
      },
    },

    default_component_configs = {
      container = {
        enable_character_fade = true,
      },
      indent = { padding = 0 },
      modified = { symbol = "●" },
      name = {
        trailing_slash = false,
        use_git_status_colors = true,
        highlight = "NeoTreeFileName",
      },
      icons = {
        folder_closed = "",
        folder_open = "",
        folder_empty = "󱧴",
        default = "󰉋",
      },
      git_status = {
        symbols = {

          -- unstaged = "󰄱",
          -- staged = "󰱒",
          -- Change type
          added = "A",
          modified = "M",
          deleted = "D", -- this can only be used in the git_status source
          renamed = "R", -- this can only be used in the git_status source
          -- Status type
          untracked = "U",
          ignored = "◌",
          unstaged = "",
          staged = "",
          conflict = "",
        },
      },
    },
    filesystem = {
      filtered_items = {
        visible = false, -- when true, they will just be displayed differently than normal items
        hide_dotfiles = true,
        hide_gitignored = false,
        hide_hidden = true, -- only works on Windows for hidden files/directories
        hide_by_name = {
          ".git",
          "node_modules",
        },
        always_show = { -- remains visible even if other settings would normally hide it
          ".gitignore",
        },
        never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
          ".DS_Store",
          "thumbs.db",
        },
      },
      follow_current_file = {
        enabled = true,
      },
      group_empty_dirs = true, -- when true, empty folders will be grouped together
    },
    buffers = {
      group_empty_dirs = true, -- when true, empty folders will be grouped together
    },
    git_status = {
      window = {
        mappings = {
          ["a"] = "git_add_file",
          ["A"] = "git_add_all",
          ["u"] = "git_unstage_file",
          -- ["gr"] = "git_revert_file",
          ["c"] = "git_commit",
          ["P"] = "git_push",
          -- ["cp"] = "git_commit_and_push",
        },
      },
    },
  }
end

return M
