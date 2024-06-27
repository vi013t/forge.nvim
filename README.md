![banner](./docs/forge-banner.png)

<center>

`Forge.nvim` provides a GUI organizing and collecting several essential plugins including `mason.nvim`, `nvim-treesitter`, and many more, as well as managing compiler and interpreter installations. `forge.nvim` also automatically sets up language servers, autocomplete, and autoformatters with no configuration necessary. The goal of Forge.nvim is to remove the hassle of setting up LSPs in Neovim.

</center>

## Demo

![demo](./docs/demo.png)

Forge.nvim provides this window in which you can install language servers, formatters, highlighters, and more with a single button press. Forge will automatically set up your LSP and related tools. The only reason you'd have to write any LSP configuration at all would be if you wanted to customize the appearance, such as changing borders or colors or icons. Otherwise, you don't have to write a single line of LSP setup.

# Example Installation & Configuration

Note that `Forge.nvim` currently **only works with lazy.nvim**. Forge has the ability to install plugins, and currently only has this ability with `lazy.nvim`. More package managers may be supported in the future. Below, you can choose from a few different installation options, such as "give me everything" and "let me choose what I need".

<details>
<summary>Full-feature no-hassle setup</summary>

```lua
{
    dir = "vi013t/forge.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter", 
        "williamboman/mason.nvim", 
        "neovim/nvim-lspconfig", 
        "williamboman/mason-lspconfig.nvim", 
        "hrsh7th/nvim-cmp",      
        "hrsh7th/cmp-nvim-lsp",  
        "hrsh7th/cmp-cmdline",   
        "hrsh7th/cmp-buffer",    
        "hrsh7th/cmp-path",      
        "onsails/lspkind.nvim",  
        "stevearc/conform.nvim", 
        "L3MON4D3/LuaSnip",      
        "j-hui/fidget.nvim",     
        "folke/lazydev.nvim",    
        "soulis-1256/eagle.nvim" 
    },
    opts = {},
}
```
</details>

<details>
<summary>Detailed Opt-in/Opt-out Setup</summary>

```lua
{
    dir = "vi013t/forge.nvim",
    dependencies = {

        -- REQUIRED
        "nvim-treesitter/nvim-treesitter", -- Semantic highlighter
        "williamboman/mason.nvim", -- LSP Installer
        "neovim/nvim-lspconfig", -- LSP Configuration
        "williamboman/mason-lspconfig.nvim", -- LSP Configuration for Mason
        "stevearc/conform.nvim", -- Autoformatter

        -- OPTIONAL
        "hrsh7th/nvim-cmp",      -- Autocomplete
        "hrsh7th/cmp-nvim-lsp",  -- LSP integration with autocomplete
        "hrsh7th/cmp-cmdline",   -- Autocomplete in command line
        "hrsh7th/cmp-buffer",    -- Autocomplete for the buffer
        "hrsh7th/cmp-path",      -- Autocomplete for file paths
        "onsails/lspkind.nvim",  -- Icons in autocomplete
        "L3MON4D3/LuaSnip",      -- Snippets
        "j-hui/fidget.nvim",     -- LSP progress updates
        "folke/lazydev.nvim",    -- Lua development tools
        "soulis-1256/eagle.nvim" -- LSP popups on mouse hovering
    },
    opts = {},
}
```
</details>

<details>
	<summary>Advanced configuration (default options)</summary>

```lua
{
    "neph-iap/forge.nvim",
    dependencies = {

        -- REQUIRED
        "nvim-treesitter/nvim-treesitter", -- Semantic highlighter
        "williamboman/mason.nvim", -- LSP Installer
        "neovim/nvim-lspconfig", -- LSP Configuration
        "williamboman/mason-lspconfig.nvim", -- LSP Configuration for Mason
        "stevearc/conform.nvim", -- Autoformatter

        -- OPTIONAL
        "hrsh7th/nvim-cmp",      -- Autocomplete
        "hrsh7th/cmp-nvim-lsp",  -- LSP integration with autocomplete
        "hrsh7th/cmp-cmdline",   -- Autocomplete in command line
        "hrsh7th/cmp-buffer",    -- Autocomplete for the buffer
        "hrsh7th/cmp-path",      -- Autocomplete for file paths
        "onsails/lspkind.nvim",  -- Icons in autocomplete
        "L3MON4D3/LuaSnip",      -- Snippets
        "j-hui/fidget.nvim",     -- LSP progress updates
        "folke/lazydev.nvim",    -- Lua development tools
        "soulis-1256/eagle.nvim" -- LSP popups on mouse hovering
    },
    opts = {
		developer_mode = false, -- Print debug messages
		lockfile = vim.fn.stdpath("data") .. "/forge.lock", -- The path to the file which saves what you have installed, so that we don't need to check every time.
		format_on_save = true, -- Autoformat buffers on save

		-- UI --
		ui = {
			mappings = {
				q = "close_window",
				e = "expand",
				j = "move_cursor_down",
				k = "move_cursor_up",
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
					{ "#FF0000" }, -- Language has no tools available
					{ "#FF0000", "#00FF00" }, -- Language has 1 tool available
					{ "#FF0000", "#FFFF00", "#00FF00" }, -- Language has 2 tools available
					{ "#FF0000", "#FFAA00", "#BBFF00", "#00FF00" }, -- Language has 3 tools available
					{ "#FF0000", "#FF8800", "#FFFF00", "#BBFF00", "#00FF00" }, -- Language has 5 tools available
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

	},
}
```

</details>

<br/>

That's it! `Forge.nvim` will automatically handle the hassle of setting up `lspconfig`, language servers, autocomplete, autoformatting, and more. Every plugin listed as a dependency here will be set up and configured automatically. If you do choose, you can set up specific options as well; See the advanced configuration above.

## What is `Forge.nvim`?

`Forge.nvim` comes with a GUI floating window with a list of over 20 programming languages. Each language can have its compiler, syntax highlighter, linter, and formatter installed through the UI with no commands or manual downloads necessary. When multiple options are available (e.g. `gcc` vs `clang` vs `zig`), the user can pick a specific one, or install the recommended automatically.

Syntax highlighters are mostly installed through `nvim-treesitter`, and linters (LSPs) are mostly installed through `mason.nvim`, which is why they are both dependencies to the plugin.

`Forge.nvim` automatically runs the setup for `mason.nvim`, `nvim-cmp`, `nvim-lspconfig`, `nvim-treesitter`, `conform.nvim`, and more.

## Why `Forge.nvim`?

A common question might be what the purpose of making `forge.nvim` is when tools like `mason.nvim` and `nvim-treesitter` already exist. The reality is, learning to program is overwhelming, especially in Neovim; The amount of tools available is huge and understanding how to set up and use these tools can take a long time. The purpose of `forge.nvim` is to streamline the devtools installation and setup process. 

Want to write C, but you've never installed anything before? Press one button, and all the power of the language is at your fingertips: The compiler, LSP, semantic highlighter, auto-formatter, debugger, and additional support plugins can all be installed with a single button press. 

`Forge.nvim` also aims to eliminate the "what's the name of the tool?" process, such as scrolling up and down `mason.nvim` looking for a Python debugger, when searching "Python" and checking under "P" doesn't seem to be helpful. Often, you'd have to search the web to discover that it's called `debugpy`. In some cases of poorly-named tools, this process is repeated for every tool of the language: the LSP, the formatter, the debugger, etc. `Forge.nvim` aims to wash away that headache by providing easy tool installation *under the name of the language*. 

In general, `forge.nvim` does not aim to provide any new or groundbreaking functionality to Neovim; Instead, it aims simply to streamline the complex process of installing developer tools. Much of this is already possible and even simple using just `mason.nvim` and `nvim-treesitter`, but `forge.nvim` aims to be so dead simple that even a five year old could figure it out without looking anything up.

## Issues

`Forge.nvim` is still in a pre-alpha state, and much of the promised functionality is not yet implemented. As such, many issues, bugs, and lacking features are known. However, feel free to make an issue regardless, and progress on that feature/bug can be tracked there.
