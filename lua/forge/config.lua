local public = Table({})

--- The default configuration options
public.default_config = {
	developer_mode = false, -- Print debug messages
	lockfile = vim.fn.stdpath("data") .. "/forge.lock", -- The path to the file which saves what you have installed, so that we don't need to check every time.
	plugin_directory = "plugins", -- The name of the plugin directory, relative to ~/.config/nvim/lua.
	format_on_save = true, -- Whether to autoformat buffers on save.

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
			presets = {
				default = {
					{ "#FF0000" }, -- Language has no tools available
					{ "#FF0000", "#00FF00" }, -- Language has 1 tool available
					{ "#FF0000", "#FFFF00", "#00FF00" }, -- Language has 2 tools available
					{ "#FF0000", "#FFAA00", "#BBFF00", "#00FF00" }, -- Language has 3 tools available
					{ "#FF0000", "#FF8800", "#FFFF00", "#BBFF00", "#00FF00" }, -- Language has 5 tools available
					{ "#FF0000", "#FF6600", "#FFAA00", "#FFFF00", "#BBFF00", "#00FF00" },
				},
				["catppuccin-mocha"] = {
					{ "#F38BA8" }, -- Language has no tools available
					{ "#F38BA8", "#A6E3A1" }, -- Language has 1 tool available
					{ "#F38BA8", "#F9E2AF", "#A6E3A1" }, -- Language has 2 tools available
					{ "#F38BA8", "#FAB387", "#DDF7A1", "#A6E3A1" }, -- Language has 3 tools available
					{ "#F38BA8", "#FA9D87", "#F9E2AF", "#DDF7A1", "#A6E3A1" }, -- Language has 5 tools available
					{ "#F38BA8", "#FA8387", "#FAB387", "#F9E2AF", "#DDF7A1", "#A6E3A1" },
				},
			},
			preset = nil,
		},

		--- Options passed to the Forge window. These can be any options from vim.opt that are window-specific,
		--- as opposed to buffer-specific options.
		window_options = {
			cursorline = true,
		},

		--- Options passed to the Forge window upon creation. For a full list of available keys and values, see
		--- the last parameter of `:h nvim_open_win`.
		window_config = {
			style = "minimal",
			relative = "editor",
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
			},
			severity_sort = true,
		},
		inlay_hints = {
			enabled = true,
		},
		capabilities = {},
		format = {
			formatting_options = nil,
			timeout_ms = nil,
		},

		-- Language Servers
		servers = {
			-- Lua
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

			-- C#
			omnisharp_mono = {
				cmd = {
					vim.fn.stdpath("data") .. "/mason/bin/omnisharp-mono",
					"--assembly-loader=strict",
				},
				use_mono = true,
			},
		},
		setup = {},
	},

	-- Autocomplete options
	autocomplete = {
		format = {
			mode = "symbol_text",

			-- Autocomplete symbols
			symbol_map = {
				Text = "",
				Method = "∷",
				Function = "λ",
				Constructor = "",
				Field = "",
				Variable = "󰫧",
				Class = "",
				Interface = "",
				Module = "",
				Property = "∷",
				Unit = "",
				Value = "",
				Enum = "",
				Keyword = "",
				Snippet = "➡️",
				Color = "",
				File = "",
				Reference = "&",
				Folder = "",
				EnumMember = "",
				Constant = "𝛫",
				Struct = "",
				Event = "",
				Operator = "",
				TypeParameter = "",
			},
		},
	},
}

-- Set the initial config to the default
public.options = public.default_config

--- Sets the config options to to the given table, or use the default for options which aren't given.
--- In other words, the passed config table will be merged into the default config, overridding any
--- options at any nesting level.
--
---@param config table The configuration to set
function public.set_config(config)
	public.options = vim.tbl_deep_extend("force", vim.deepcopy(public.options), config)
end

return public
