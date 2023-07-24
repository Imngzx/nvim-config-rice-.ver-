-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local icons = require("icons")

-- empty setup using defaults
require("nvim-tree").setup {
	auto_reload_on_write = true,
	create_in_closed_folder = false,
	disable_netrw = false,
	hijack_cursor = true,
	hijack_netrw = true,
	hijack_unnamed_buffer_when_opening = true,
	open_on_tab = false,
	respect_buf_cwd = false,
	sort_by = "name",
	sync_root_with_cwd = true,
	view = {
		adaptive_size = false,
		centralize_selection = false,
		width = 28,
		side = "left",
		preserve_window_proportions = false,
		number = false,
		relativenumber = false,
		signcolumn = "yes",
		float = {
			enable = false,
			open_win_config = {
				relative = "editor",
				border = "rounded",
				width = 28,
				height = 28,
				row = 1,
				col = 1,
			},
		},
	},
	renderer = {
		add_trailing = false,
		group_empty = true,
		highlight_git = true,
		full_name = false,
		highlight_opened_files = "none",
		special_files = { "Cargo.toml", "Makefile", "README.md", "readme.md", "CMakeLists.txt" },
		symlink_destination = true,
		indent_markers = {
      enable = true,
      inline_arrows = false,
			icons = {
				corner = "└ ",
				edge = "│ ",
				item = "│ ",
				none = "  ",
			},
		},
		root_folder_label = ":.:s?.*?/..?",
		icons = {
			webdev_colors = true,
			git_placement = "after",
			show = {
				file = true,
				folder = true,
				folder_arrow = false,
				git = true,
			},
			padding = " ",
			symlink_arrow = " " .. icons.arrows.Right .. " ",
			glyphs = {
				default = icons.files.Defalt,
				symlink = icons.files.Symlink,
				bookmark = icons.files.Bookmark,
				git = {
					untracked = icons.git.Untracked,
					renamed = icons.git.Renamed,
					deleted = icons.git.Deleted,
					unstaged = icons.git.Unstaged,
					staged = icons.git.Staged,
					unmerged = icons.git.Unmerged,
					-- ignored = icons.git.Ignored,
          ignored = "",
				},
				folder = {
					-- arrow_open = icons.arrows.ArrowOpen,
					-- arrow_closed = icons.arrows.ArrowClosed,
					default = icons.folders.Default,
					open = icons.folders.Open,
					empty = icons.folders.Empty,
					empty_open = icons.folders.EmptyOpen,
					symlink = icons.folders.Symlink,
					symlink_open = icons.folders.SymlinkOpen,
				},
			},
		},
	},
	hijack_directories = {
		enable = true,
		auto_open = true,
	},
	update_focused_file = {
		enable = true,
		-- update_root = true,
		ignore_list = {},
	},
	filters = {
		dotfiles = false,
		custom = { ".DS_Store" },
		exclude = {},
	},
	actions = {
		use_system_clipboard = true,
		change_dir = {
			enable = true,
			global = false,
		},
		open_file = {
			quit_on_open = false,
			window_picker = {
				enable = true,
				chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
				exclude = {
					filetype = { "notify", "qf", "diff", "fugitive", "fugitiveblame" },
					buftype = { "terminal", "help" },
				},
			},
		},
		remove_file = {
			close_window = true,
		},
	},
	diagnostics = {
		enable = false,
		show_on_dirs = false,
		debounce_delay = 50,
		icons = {
			-- hint = icons.diagnostics.Hint_alt,
			-- info = icons.diagnostics.Information_alt,
			-- warning = icons.diagnostics.Warning_alt,
			-- error = icons.diagnostics.Error_alt,
		},
	},
	filesystem_watchers = {
		enable = true,
		debounce_delay = 50,
	},
	git = {
		enable = true,
		ignore = false,
		show_on_dirs = true,
		timeout = 400,
	},
	trash = {
		cmd = "gio trash",
		require_confirm = true,
	},
	live_filter = {
		prefix = "[FILTER]: ",
		always_show_folders = true,
	},
	log = {
		enable = false,
		truncate = false,
		types = {
			all = false,
			config = false,
			copy_paste = false,
			dev = false,
			diagnostics = false,
			git = false,
			profile = false,
			watcher = false,
		},
	},
}
