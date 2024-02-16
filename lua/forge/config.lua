local public = Table({})

public.default_config = {
	developer_mode = false, -- Print debug messages
	lockfile = vim.fn.stdpath("data") .. "/forge.lock", -- The path to the file which saves what you have installed, so that we don't need to check every time.
	format_on_save = true, -- Autoformat buffers on save

	-- UI --
	ui = {
		mappings = {
			q = "close_window",
			e = "expand",
			j = "move_cursor_down", -- TODO: Use CursorMove events so that these don't have to be done manually
			k = "move_cursor_up", -- 		 which will also allow support for more motions
			gg = "set_cursor_to_top",
			G = "set_cursor_to_bottom",
			i = "toggle_install",
			u = "toggle_install",
			r = "refresh",
			o = "open_options",
			["<C-d>"] = "do_nothing",
			["<CR>"] = "move_cursor_down",
			["<Up>"] = "move_cursor_up",
			["<Down>"] = "move_cursor_down",
		},
		symbols = {
			right_arrow = "▸",
			down_arrow = "▾",
			progress_icons = {
				{ "" },
				{ "", "" },
				{ "", "", "" },
				{ "", "", "", "" },
				{ "", "", "", "", "" },
				{ "", "", "", "", "", "" },
			},
		},
		colors = {
			progress_colors = {
				{ "#FF0000" },
				{ "#FF0000", "#00FF00" },
				{ "#FF0000", "#FFFF00", "#00FF00" },
				{ "#FF0000", "#FFAA00", "#BBFF00", "#00FF00" },
				{ "#FF0000", "#FF8800", "#FFFF00", "#BBFF00", "#00FF00" },
				{ "#FF0000", "#FF6600", "#FFAA00", "#FFFF00", "#BBFF00", "#00FF00" },
			},
		},
	},

	-- LSP --
	lsp = {
		icons = {
			Error = " ",
			Warn = " ",
			Hint = " ",
			Info = " ",
		},
		diagnostics = {
			underline = true,
			update_in_insert = false,
			virtual_text = {
				spacing = 4,
				source = "if_many",
				prefix = "",
			},
			severity_sort = true,
		},
		inlay_hints = {
			enabled = false,
		},
		capabilities = {},
		format = {
			formatting_options = nil,
			timeout_ms = nil,
		},
		servers = {
			lua_ls = {
				settings = {
					Lua = {
						workspace = {
							checkThirdParty = false,
						},
						completion = {
							callSnippet = "Replace",
						},
					},
				},
			},
			omnisharp = {
				cmd = {
					"mono",
				},
				use_mono = true,
			},
		},
		setup = {},
	},
}

public.options = public.default_config

function public.set_config(config)
	public.config = vim.tbl_deep_extend("force", vim.deepcopy(public.options), config)
end

return public
