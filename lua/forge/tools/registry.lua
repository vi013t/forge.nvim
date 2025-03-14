local config = require("forge.config")

--- The registry module. This is where all of the languages and tools that Forge uses are stored. Additionally,
--- there are some utility functions, such as getting a language object based on its name, or sorting the list
--- of languages.
local registry = {}

---@class GlobalTool
---@field name string
---@field entries GlobalToolEntry[]
---@field installed_entries number | nil
---@field pinned? boolean

---@class GlobalToolEntry
---@field name string
---@field internal_name string
---@field module string
---@field is_installed boolean | nil
---@field default_config string
---@field recommended boolean
---@field pinned? boolean

---@alias Tool { name: string, internal_name: string, pinned?: boolean }
---
---@class Language
---
---@field name string
---@field compiler_type? string
---@field packages? table<string, string>
---@field pinned? boolean
---
---@field highlighters Tool[]
---@field compilers Tool[]
---@field formatters Tool[]
---@field debuggers Tool[]
---@field linters Tool[]
---@field additional_tools any[]
---@field total? integer
---
---@field installed_highlighters? string[]
---@field installed_debuggers? Tool[]
---@field installed_formatters? Tool[]
---@field installed_compilers? Tool[]
---@field installed_linters? Tool[]
---@field installed_additional_tools? Tool[]
---@field installed_total? integer

-- NOTE: when making dev changes to the registry, you'll need to delete your lockfile to see the changes.
-- This is located at vim.fn.stdpath("data") .. "/forge.lock", which in most cases for linux is ~/.local/share/nvim/forge.lock,
-- and for windows is %localappdata%/nvim-data/forge.lock

---@type table<string, GlobalTool>
registry.global_tools = {
	autocomplete = {
		name = "Autocomplete",
		entries = {
			{
				name = "Blink Autocomplete",
				internal_name = "saghen/blink.cmp",
				recommended = true,
				module = "blink_cmp",
				default_config = [[
					version = "*",
					event = "InsertEnter",
					opts = {
						keymap = { preset = 'super-tab' },
						appearance = { nerd_font_variant = 'normal' },
						sources = {
							default = { "lazydev", 'lsp', 'path', 'snippets', 'buffer' },
							providers = {
								lazydev = {
									name = "LazyDev",
									module = "lazydev.integrations.blink",
									score_offset = 100,
								},
							},
						},
					},
					opts_extend = { "sources.default" }
				]],
			},
			-- {
			-- 	name = "Autocomplete Core",
			-- 	internal_name = "hrsh7th/nvim-cmp",
			-- 	recommended = false,
			-- 	module = "cmp",
			-- 	default_config = ([[
			-- 		config = function()
			-- 			local has_cmp, cmp = pcall(require, "cmp")
			--
			-- 			if has_cmp then
			-- 				local primary_sources = {}
			-- 				local secondary_sources = {}
			--
			-- 				-- lspkind
			-- 				local has_lspkind, lspkind = pcall(require, "lspkind")
			-- 				local formatting = nil
			-- 				if has_lspkind then
			-- 					formatting = {
			-- 						format = lspkind.cmp_format(%s),
			-- 					}
			-- 				end
			--
			-- 				-- LuaSnip
			-- 				local snippet = nil
			-- 				local has_luasnip, luasnip = pcall(require, "luasnip")
			-- 				if has_luasnip then
			-- 					snippet = {
			-- 						expand = function(args)
			-- 							luasnip.lsp_expand(args.body)
			-- 						end
			-- 					}
			-- 					table.insert(primary_sources, { name = "luasnip "})
			-- 				end
			--
			-- 				-- CMP LSP
			-- 				local has_cmp_lsp = pcall(require, "cmp_nvim_lsp")
			-- 				if has_cmp_lsp then
			-- 					table.insert(primary_sources, { name = "nvim_lsp"} )
			-- 				end
			--
			-- 				-- CMP Buffer
			-- 				local has_cmp_buffer = pcall(require, "cmp-buffer")
			-- 				if has_cmp_buffer then
			-- 					table.insert(secondary_sources, { name = "buffer" })
			-- 				end
			--
			-- 				-- CMP
			-- 				cmp.setup({
			-- 					snippet = snippet,
			-- 					mapping = cmp.mapping.preset.insert({
			-- 						["<C-b>"] = cmp.mapping.scroll_docs(-4),
			-- 						["<C-f>"] = cmp.mapping.scroll_docs(4),
			-- 						["<C-Space>"] = cmp.mapping.complete(),
			-- 						["<C-e>"] = cmp.mapping.abort(),
			-- 						["<CR>"] = cmp.mapping.confirm({ select = true }),
			-- 					}),
			-- 					sources = cmp.config.sources(primary_sources, secondary_sources),
			-- 					formatting = formatting,
			-- 				})
			--
			-- 				-- CMDline
			-- 				local has_cmp_cmd = pcall(require, "cmp_cmdline")
			-- 				if has_cmp_cmd then
			-- 					cmp.setup.cmdline({ "/", "?" }, {
			-- 						mapping = cmp.mapping.preset.cmdline(),
			-- 						sources = secondary_sources,
			-- 					})
			--
			-- 					cmp.setup.cmdline(":", {
			-- 						mapping = cmp.mapping.preset.cmdline(),
			-- 						sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
			-- 					})
			-- 				end
			-- 			end
			-- 		end,
			-- 		event = "InsertEnter"
			-- 	]]):format(vim.inspect(config.options.autocomplete.format)),
			-- },
			-- {
			-- 	name = "Autcomplete LSP integration",
			-- 	internal_name = "hrsh7th/cmp-nvim-lsp",
			-- 	recommended = false,
			-- 	module = "cmp_nvim_lsp",
			-- 	default_config = [[
			-- 		event = "InsertEnter"
			-- 	]],
			-- },
			-- {
			-- 	name = "Command Line Autocompletion",
			-- 	internal_name = "hrsh7th/cmp-cmdline",
			-- 	recommended = false,
			-- 	module = "cmp_cmdline",
			-- 	default_config = [[
			-- 		event = "InsertEnter"
			-- 	]],
			-- },
			-- {
			-- 	name = "Buffer Content Autocompletion",
			-- 	internal_name = "hrsh7th/cmp-buffer",
			-- 	recommended = true,
			-- 	module = "cmp_buffer",
			-- 	default_config = [[
			-- 		event = "InsertEnter"
			-- 	]],
			-- },
			-- {
			-- 	name = "File Path Autocompletion",
			-- 	internal_name = "hrsh7th/cmp-path",
			-- 	recommended = false,
			-- 	module = "cmp_path",
			-- 	default_config = [[
			-- 		event = "InsertEnter"
			-- 	]],
			-- },
			-- {
			-- 	name = "Autocomplete Icons",
			-- 	internal_name = "onsails/lspkind.nvim",
			-- 	recommended = false,
			-- 	module = "lspkind",
			-- 	default_config = [[
			-- 		event = "InsertEnter"
			-- 	]],
			-- },
		},
	},
	lsp_status = {
		name = "Language Server Status",
		entries = {
			{
				name = "Language Server Loading Progress",
				internal_name = "j-hui/fidget.nvim",
				recommended = true,
				module = "fidget",
				default_config = [[
					opts = {}
				]],
			},
		},
	},
	mouse_support = {
		name = "Mouse Support",
		entries = {
			{
				name = "Mouse Hover Info",
				internal_name = "soulis-1256/eagle.nvim",
				recommended = true,
				module = "eagle",
				default_config = [[
					config = function()
						require("eagle").setup({})
						vim.opt.mousemoveevent = true
					end
				]],
			},
		},
	},
	snippets = {
		name = "Snippets",
		entries = {
			{
				name = "Lua Snippets",
				internal_name = "L3MON4D3/LuaSnip",
				recommended = true,
				module = "luasnip",
				default_config = [[
					event = "InsertEnter",
					build = "make install_jsregexp"
				]],
			},
			{
				name = "Snippets",
				internal_name = "norcalli/snippets.nvim",
				recommended = false,
				module = "snippets",
				default_config = [[
					event = "InsertEnter",
				]],
			},
			{
				name = "Snippy",
				internal_name = "dcampos/nvim-snippy",
				recommended = false,
				module = "snippy",
				default_config = [[
					event = "InsertEnter",
					opts = {}
				]],
			},
			{
				name = "Friendly Snippets",
				internal_name = "rafamadriz/friendly-snippets",
				recommended = false,
				module = "friendly-snippets",
				default_config = [[
					event = "InsertEnter",
				]],
			},
			{
				name = "Scissors",
				internal_name = "chrisgrieser/nvim-scissors",
				recommended = false,
				module = "scissors",
				default_config = [[
					event = "InsertEnter",
					opts = {}
				]],
			},
			{
				name = "Tesoura",
				internal_name = "guilherme-puida/tesoura.nvim",
				recommended = false,
				module = "tesoura",
				default_config = [[
					event = "InsertEnter",
					opts = {}
				]],
			},
			{
				name = "Snippet Converter",
				internal_name = "smjonas/snippet-converter.nvim",
				recommended = false,
				module = "snippet-converter",
				default_config = [[
					event = "InsertEnter",
					opts = {}
				]],
			},
		},
	},
	code_actions = {
		name = "Code Actions",
		entries = {
			{
				name = "Lightbulb",
				internal_name = "kosayoda/nvim-lightbulb",
				recommended = true,
				module = "nvim-lightbulb",
				default_config = [[
					opts = {
						autocmd = { enabled = true }
					}
				]],
			},
			{
				name = "Actions Preview",
				internal_name = "aznhe21/actions-preview.nvim",
				recommended = false,
				module = "actions-preview",
				default_config = [[
					config = function()
						vim.keymap.set({ "v", "n" }, "gf", require("actions-preview").code_actions)
					end,
				]],
			},
			{
				name = "Tiny Code Action",
				internal_name = "rachartier/tiny-code-action.nvim",
				recommended = false,
				module = "tiny-code-action",
				default_config = [[
					dependencies = {
						{"nvim-lua/plenary.nvim"},
						{"nvim-telescope/telescope.nvim"},
					},
					event = "LspAttach",
					config = function()
						require('tiny-code-action').setup()
					end
				]],
			},
		},
	},
}

registry.global_tool_keys = table_metatable({})
do
	for name, _ in pairs(registry.global_tools) do
		registry.global_tool_keys:insert(name)
	end
end

---@type table<string, Language>
registry.languages = {
	bash = {
		name = "Bash",
		compiler_type = "interpreter",
		highlighters = {
			{ internal_name = "bash", name = "TreeSitter" },
		},
		compilers = {
			{ internal_name = "bash", name = "Bash" },
		},
		formatters = {},
		linters = {
			{ internal_name = "bash-language-server", name = "Bash Language Server" },
		},
		debuggers = {
			{ internal_name = "bash-debug-adapter", name = "Bash Debug Adapter" },
		},
		additional_tools = {},
	},
	c = {
		name = "C",
		compiler_type = "compiler",
		highlighters = {
			{ internal_name = "c", name = "TreeSitter" },
		},
		compilers = {
			{ internal_name = "cc", name = "Custom C Compiler" },
			{ internal_name = "clang", name = "Clang Compiler" },
			{ internal_name = "gcc", name = "GNU C Compiler" },
			{ internal_name = "tcc", name = "Tiny C Compiler" },
			{ internal_name = "zig", name = "Zig C Compiler" },
		},
		formatters = {
			{ internal_name = "clang-format", name = "Clang Format" },
		},
		linters = {
			{ internal_name = "clangd", name = "Clang Daemon" },
		},
		debuggers = {
			{ internal_name = "cpptools", name = "C++ Tools" },
		},
		additional_tools = {},
	},
	cpp = {
		name = "C++",
		compiler_type = "compiler",
		highlighters = {
			{ internal_name = "cpp", name = "TreeSitter" },
		},
		compilers = {
			{ internal_name = "cc", name = "Custom C Compiler" },
			{ internal_name = "gcc", name = "GNU C Compiler" },
			{ internal_name = "tcc", name = "Tiny C Compiler" },
			{ internal_name = "clang", name = "Clang Compiler" },
			{ internal_name = "zig", name = "Zig C Compiler" },
		},
		formatters = {
			{ internal_name = "clang-format", name = "Clang Format" },
		},
		linters = {
			{ internal_name = "clangd", name = "Clang Daemon" },
			{ internal_name = "cpplint", name = "C++ Linter" },
		},
		debuggers = {
			{ internal_name = "cpptools", name = "C++ Tools" },
		},
		additional_tools = {},
		extensions = { "h", "cpp", "hpp", "cxx", "cc", "c++", "hxx", "hh", "h++" },
	},
	csharp = {
		name = "C#",
		compiler_type = "compiler",
		highlighters = {
			{ internal_name = "c_sharp", name = "TreeSitter" },
		},
		compilers = {
			{ internal_name = "dotnet", name = ".NET SDK" },
		},
		linters = {
			{ internal_name = "omnisharp-mono", name = "Omnisharp Mono" },
		},
		debuggers = {},
		formatters = {
			{ internal_name = "csharpier", name = "C Sharpier" },
		},
		additional_tools = {
			{
				type = "plugin",
				internal_name = "iabdelkareem/csharp.nvim",
				name = "C# Tools for Neovim",
			},
		},
	},
	elixir = {
		name = "Elixir",
		compiler_type = "compiler",
		compilers = {
			{ internal_name = "elixir", name = "Elixir Compiler" },
		},
		highlighters = {
			{ internal_name = "elixir", name = "TreeSitter" },
		},
		linters = {
			{ internal_name = "elixir-ls", name = "Elixir Language Server" },
		},
		debuggers = {},
		formatters = {},
		additional_tools = {},
	},
	go = {
		name = "Go",
		compiler_type = "compiler",
		highlighters = {
			{ internal_name = "go", name = "TreeSitter" },
		},
		compilers = {
			{ internal_name = "go", name = "Go Compiler" },
		},
		formatters = {
			{ internal_name = "gofumpt", name = "Strict Go Formatter" },
		},
		linters = {
			{ internal_name = "gopls", name = "Go Programming Language Server" },
		},
		debuggers = {
			{ internal_name = "go-debug-adapter", name = "Go Debug Adapter" },
		},
		additional_tools = {
			{
				type = "plugin",
				internal_name = "ray-x/go.nvim",
				name = "Go Tools for Neovim",
			},
			{
				type = "plugin",
				internal_name = "crusj/structure-go.nvim",
				name = "Go Symbol Outline",
			},
		},
		packages = {
			choco = "golang",
		},
	},
	haskell = {
		name = "Haskell",
		compiler_type = "compiler",
		highlighters = {
			{ internal_name = "haskell", name = "TreeSitter" },
		},
		compilers = {
			{ internal_name = "haskell", name = "Haskell" },
		},
		linters = {
			{ internal_name = "haskell-language-server", name = "Haskell Language Server" },
		},
		debuggers = {
			{ internal_name = "haskell-debug-adapter", name = "Haskell Debug Adapter" },
		},
		formatters = {},
		additional_tools = {},
	},
	html = {
		name = "HTML",
		highlighters = {
			{ internal_name = "html", name = "TreeSitter" },
		},
		compilers = {},
		formatters = {
			{ internal_name = "prettier", name = "Prettier" },
		},
		linters = {
			{ internal_name = "html-lsp", name = "HTML Language Server" },
			{ internal_name = "emmet-language-server", name = "Emmet Language Server" },
			{ internal_name = "emmet-ls", name = "Emmet Language Server (2)" },
			{ internal_name = "tailwindcss-language-server", name = "Tailwind CSS Language Server" },
			{ internal_name = "rustywind", name = "Rusty Wind" },
		},
		debuggers = {},
		additional_tools = {
			{
				type = "plugin",
				internal_name = "roobert/tailwindcss-colorizer-cmp.nvim",
				name = "Tailwind CSS colorizer & autocomplete",
			},
		},
	},
	java = {
		name = "Java",
		compiler_type = "compiler",
		highlighters = {
			{ internal_name = "java", name = "TreeSitter" },
		},
		compilers = {
			{ internal_name = "java", name = "Java Compiler" },
		},
		formatters = {
			{ internal_name = "google-java-format", name = "Google Java Formatter" },
		},
		linters = {
			{ internal_name = "java-language-server", name = "Java Language Server" },
			{ internal_name = "gradle-language-server", name = "Gradle Language Server" },
		},
		debuggers = {
			{ internal_name = "java-debug-adapter", name = "Java Debug Adapter" },
		},
		additional_tools = {
			{
				type = "mason",
				internal_name = "vscode-java-decompiler",
				name = "Java Decompiler",
			},
			{
				type = "plugin",
				internal_name = "simaxme/java.nvim",
				name = "Java Refactorer",
			},
		},
	},
	javascript = {
		name = "JavaScript",
		compiler_type = "interpreter",
		highlighters = {
			{ internal_name = "javascript", name = "TreeSitter" },
		},
		compilers = {
			{ internal_name = "node", name = "NodeJS" },
		},
		linters = {
			{ internal_name = "eslint-lsp", name = "EcmaScript Lint Language Server" },
		},
		formatters = {
			{ internal_name = "prettier", name = "Prettier" },
		},
		debuggers = {
			{ internal_name = "js-debug-adapter", name = "JavaScript Debug Adapter" },
			{ internal_name = "chrome-debug-adapter", name = "Chrome Debug Adapter" },
		},
		additional_tools = {},
		extensions = { "js", "jsx" },
	},
	json = {
		name = "JSON",
		highlighters = {
			{ internal_name = "json", name = "TreeSitter" },
		},
		compilers = {},
		linters = {
			{ internal_name = "json-lsp", name = "JSON Language Server" },
		},
		formatters = {
			{ internal_name = "prettier", name = "Prettier" },
		},
		debuggers = {},
		additional_tools = {},
	},
	julia = {
		name = "Julia",
		compiler_type = "compiler",
		highlighters = {
			{ internal_name = "julia", name = "TreeSitter" },
		},
		compilers = {
			{ internal_name = "julia", name = "Julia Compiler" },
		},
		linters = {
			{ internal_name = "julia-lsp", name = "Julia Language Server" },
		},
		formatters = {},
		debuggers = {},
		additional_tools = {},
	},
	kotlin = {
		name = "Kotlin",
		compiler_type = "compiler",
		highlighters = {
			{ internal_name = "kotlin", name = "TreeSitter" },
		},
		compilers = {
			{ internal_name = "kotlin", name = "Kotlin Compiler" },
		},
		formatters = {
			{ internal_name = "ktlint", name = "Kotlin Linter (with Formatter)" },
		},
		linters = {
			{ internal_name = "kotlin-language-server", name = "Kotlin Language Server" },
		},
		debuggers = {
			{ internal_name = "kotlin-debug-adapter", name = "Kotlin Debug Adapter" },
		},
		additional_tools = {},
	},
	lua = {
		name = "Lua",
		compiler_type = "interpreter",
		highlighters = {
			{ internal_name = "lua", name = "TreeSitter" },
			{ internal_name = "luadoc", name = "TreeSitter for Documentation" },
		},
		compilers = {
			{ internal_name = "lua", name = "Lua Interpreter" },
			{ internal_name = "luajit", name = "Lua Just-in-Time Compiler" },
		},
		linters = {
			{ internal_name = "lua-language-server", name = "Lua Language Server" },
		},
		formatters = {
			{ internal_name = "stylua", name = "Stylua" },
		},
		debuggers = {},
		additional_tools = {
			{
				type = "plugin",
				internal_name = "folke/lazydev.nvim",
				name = "Lazydev",
				module = "lazydev",
				default_config = [[
					opts = {},
					ft = "lua"
				]],
				recommended = true,
			},
		},
	},
	markdown = {
		name = "Markdown",
		highlighters = {
			{ internal_name = "markdown", name = "TreeSitter" },
			{ internal_name = "html", name = "TreeSitter for HTML" },
		},
		compilers = {},
		linters = {
			{ internal_name = "markdownlint", name = "Markdown Linter" },
		},
		formatters = {
			{ internal_name = "mdformat", name = "Markdown Formatter" },
		},
		debuggers = {},
		additional_tools = {
			{
				type = "plugin",
				internal_name = "OXY2DEV/markview.nvim",
				name = "Markview",
				module = "markview",
				default_config = [[
					dependencies = {
						"nvim-treesitter/nvim-treesitter",
						"nvim-tree/nvim-web-devicons",
					},
					opts = {
						modes = { "n", "no", "c" },
						hybrid_modes = { "n" },
						callbacks = {
							on_enable = function(_, win)
								vim.wo[win].conceallevel = 2
								vim.wo[win].conecalcursor = "c"
							end,
						},
					},
					ft = "markdown"
				]],
			},
			{
				type = "plugin",
				internal_name = "iamcco/markdown-preview.nvim",
				name = "Markdown Preview",
				module = "markdown-preview",
				default_config = [[
					cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
					ft = { "markdown" },
					build = function() vim.fn["mkdp#util#install"]() end
				]],
			},
			{
				type = "plugin",
				internal_name = "ellisonleao/glow.nvim",
				name = "Glow for Neovim",
				module = "glow",
				default_config = [[
					opts = {}
				]],
			},
			{
				type = "plugin",
				internal_name = "jghauser/follow-md-links.nvim",
				name = "Follow Markdown Links",
				module = "follow-md-links",
			},
			{
				type = "cli",
				name = "Pandoc",
				internal_name = "pandoc",
			},
			{
				type = "plugin",
				internal_name = "davidgranstrom/nvim-markdown-preview",
				name = "Neovim Markdown Preview",
			},
			{
				type = "plugin",
				internal_name = "jubnzv/mdeval.nvim",
				name = "Markdown Evaluator",
				module = "mdeval",
				default_config = [[
					opts = {}
				]],
			},
			{
				type = "plugin",
				internal_name = "AcksID/nvim-FeMaco.lua",
				name = "FeMaCo",
				module = "femaco",
				default_config = [[
					opts = {}
				]],
			},
			{
				type = "plugin",
				internal_name = "Zeioth/markmap.nvim",
				name = "Markmap",
				module = "markmap",
				default_config = [[
					build = "yarn global add markmap-cli",
					cmd = { "MarkmapOpen", "MarkmapSave", "MarkmapWatch", "MarkmapWatchStop" },
					opts = {
						html_output = "/tmp/markmap.html", -- (default) Setting a empty string "" here means: [Current buffer path].html
						hide_toolbar = false, -- (default)
						grace_period = 3600000 -- (default) Stops markmap watch after 60 minutes. Set it to 0 to disable the grace_period.
					},
				]],
			},
			{
				type = "plugin",
				internal_name = "jmbuhr/otter.nvim",
				name = "Otter",
				module = "otter",
				default_config = [[
					dependencies = {
						"nvim-treesitter/nvim-treesitter",
					},
					opts = {},
				]],
			},
		},
	},
	ocaml = {
		name = "OCaml",
		compiler_type = "compiler",
		highlighters = {
			{ internal_name = "ocaml", name = "TreeSitter" },
		},
		compilers = {
			{ internal_name = "ocaml", name = "OCaml Compiler" },
		},
		linters = {
			{ internal_name = "ocaml-lsp", name = "OCaml Language Server" },
		},
		formatters = {
			{ internal_name = "ocamlformat", name = "OCaml Format" },
		},
		debuggers = {},
		additional_tools = {},
	},
	python = {
		name = "Python",
		compiler_type = "interpreter",
		highlighters = {
			{ internal_name = "python", name = "TreeSitter" },
		},
		compilers = {
			{ internal_name = "python", name = "Python Interpreter" },
		},
		linters = {
			{ internal_name = "pyright", name = "Pyright" },
		},
		formatters = {
			{ internal_name = "black", name = "Black PEP8 Formatter" },
			{ internal_name = "autoflake", name = "Autoflake" },
		},
		debuggers = {
			{ internal_name = "debugpy", name = "DebugPY" },
		},
		additional_tools = {
			{
				type = "plugin",
				internal_name = "AckslD/swenv.nvim",
				module = "swenv",
				name = "Swenv",
				default_config = "",
			},
		},
	},
	r = {
		name = "R",
		compiler_type = "interpreter",
		compilers = {
			{ internal_name = "R", name = "R Interpreter" },
			{ internal_name = "Rscript", name = "R-Script" },
		},
		highlighters = {
			{ internal_name = "r", name = "TreeSitter" },
		},
		linters = {
			{ internal_name = "r-languageserver", name = "R Language Server" },
		},
		formatters = {},
		debuggers = {},
		additional_tools = {},
	},
	ruby = {
		name = "Ruby",
		compiler_type = "interpreter",
		highlighters = {
			{ internal_name = "ruby", name = "TreeSitter" },
		},
		compilers = {
			{ internal_name = "ruby", name = "Ruby Interpreter" },
		},
		linters = {
			{ internal_name = "ruby-lsp", name = "Ruby Language Server" },
		},
		formatters = {
			{ internal_name = "rubyfmt", name = "Ruby Formatter" },
		},
		debuggers = {},
		additional_tools = {},
	},
	rust = {
		name = "Rust",
		compiler_type = "compiler",
		highlighters = {
			{ internal_name = "rust", name = "TreeSitter" },
		},
		compilers = {
			{
				internal_name = "cargo",
				name = "Cargo",
				unix_install = "curl --proto '=https' --tlsv1.3 https://sh.rustup.rs -sSf | sh",
				windows_install = "choco install rustup.install",
				unix_uninstall = "rustup self uninstall",
				windows_uninstall = "rustup self uninstall",
			},
		},
		formatters = {
			{ internal_name = "rustfmt", name = "Rust Format" },
		},
		linters = {
			{ internal_name = "rust-analyzer", name = "Rust Analyzer" },
		},
		debuggers = {},
		additional_tools = {
			{
				type = "plugin",
				internal_name = "rust-lang/rust.vim",
				name = "Rust Vim Support",
			},
			{
				type = "plugin",
				internal_name = "vxpm/ferris.nvim",
				name = "Ferris",
			},
			{
				type = "plugin",
				internal_name = "mrcjkb/rustaceanvim",
				name = "Rustaceaneovim",
			},
		},
	},
	svelte = {
		name = "Svelte",
		compilers = {
			{ internal_name = "npm", name = "Node Package Manager" },
		},
		highlighters = {
			{ internal_name = "svelte", name = "TreeSitter" },
		},
		linters = {
			{ internal_name = "svelte-language-server", name = "Svelte Language Server" },
		},
		formatters = {
			{ internal_name = "prettier", name = "Prettier" },
		},
		debuggers = {},
		additional_tools = {},
	},
	swift = {
		name = "Swift",
		compiler_type = "compiler",
		highlighters = {
			{ internal_name = "swift", name = "TreeSitter" },
		},
		compilers = {
			{ internal_name = "swift", name = "Swift Compiler" },
		},
		linters = {},
		formatters = {},
		debuggers = {},
		additional_tools = {},
	},
	teal = {
		name = "Teal",
		compiler_type = "transpiler",
		compilers = {
			{ internal_name = "tl", name = "Teal Transpiler" },
		},
		highlighters = {
			{ internal_name = "teal", name = "TreeSitter" },
		},
		linters = {
			{ internal_name = "teal-language-server", name = "Teal Language Server" },
		},
		formatters = {},
		debuggers = {},
		additional_tools = {},
	},
	toml = {
		name = "TOML",
		compilers = {},
		highlighters = {
			{ internal_name = "toml", name = "TreeSitter" },
		},
		linters = {},
		formatters = {},
		debuggers = {},
		additional_tools = {},
		extenstions = { "toml" },
	},
	typescript = {
		name = "TypeScript",
		compiler_type = "transpiler",
		highlighters = {
			{ internal_name = "typescript", name = "TypeScript TreeSitter" },
			{ internal_name = "tsx", name = "TypeScript + React TreeSitter" },
		},
		compilers = {
			{ internal_name = "tsc", name = "TypeScript Transpiler" },
		},
		linters = {
			{ internal_name = "typescript-language-server", name = "TypeScript Language Server" },
			{ internal_name = "angular-language-server", name = "Angular Language Server" },
		},
		formatters = {
			{ internal_name = "prettier", name = "Prettier" },
		},
		debuggers = {},
		additional_tools = {
			{
				type = "plugin",
				internal_name = "marilari88/twoslash-queries.nvim",
				name = "Two Slash Queries",
				module = "twoslash-queries",
			},
			{
				type = "plugin",
				internal_name = "dmmulroy/ts-error-translator.nvim",
				name = "TypeScript Error Translator",
				module = "ts-error-translator",
			},
		},
	},
	v = {
		name = "V",
		compiler_type = "compiler",
		highlighters = {
			{ internal_name = "v", name = "TreeSitter" },
		},
		compilers = {
			{ internal_name = "v", name = "V Compiler" },
		},
		linters = {
			{ internal_name = "vls", name = "V Language Server" },
		},
		formatters = {},
		debuggers = {},
		additional_tools = {},
		extensions = { "v" },
		icon = "󱂌",
		color = "#519ABA",
	},
	yaml = {
		name = "YAML",
		highlighters = {
			{ internal_name = "yaml", name = "TreeSitter" },
		},
		compilers = {},
		linters = {
			{ internal_name = "yaml-language-server", name = "YAML Language Server" },
		},
		formatters = {
			{ internal_name = "yamlfmt", name = "YAML Formatter" },
		},
		debuggers = {},
		additional_tools = {
			{
				type = "plugin",
				internal_name = "someone-stole-my-name/yaml-companion.nvim",
				name = "YAML Companion",
				module = "yaml-companion",
			},
			{
				type = "plugin",
				internal_name = "cuducos/yaml.nvim",
				name = "YAML Path Tools",
				module = "yaml",
			},
		},
	},
	zig = {
		name = "Zig",
		compiler_type = "compiler",
		highlighters = {
			{ internal_name = "zig", name = "TreeSitter" },
		},
		compilers = {
			{
				internal_name = "zig",
				name = "Zig Compiler",
			},
		},
		formatters = {},
		linters = {
			{ internal_name = "zls", name = "Zig Language Server" },
		},
		debuggers = {},
		additional_tools = {
			{ internal_name = "NTBBloodbath/zig-tools.nvim", name = "Zig Tools for Neovim" },
		},
	},
}

--- Generates the language keys table. This creates a list of all unique language IDs, stored at
--- `registry.language_keys`.
---
--- @return nil
function registry.generate_language_keys()
	registry.language_keys = table_metatable({})
	for key, _ in pairs(registry.languages) do
		registry.language_keys:insert(key)
	end
end

--- Sorts `registry.language_keys`. Languages with more "percent installed" tools will be put first. If two
--- languages have the same percent of tools installed, they will be sorted alphabetically.
---
--- @return nil
function registry.sort_languages()
	registry.language_keys:sort(function(first, second)
		-- If one of them is pinned, that one comes first
		if registry.languages[first].pinned and not registry.languages[second].pinned then
			return true
		end
		if registry.languages[second].pinned and not registry.languages[first].pinned then
			return false
		end

		-- Otherwise, we put the one with the greater percent installed first
		local first_percent = math.floor(100 * ((registry.languages[first].installed_total - 1) / (registry.languages[first].total - 1)))
		local second_percent = math.floor(100 * ((registry.languages[second].installed_total - 1) / (registry.languages[second].total - 1)))
		if first_percent > second_percent then
			return true
		elseif first_percent < second_percent then
			return false

			-- If they're the same, we sort them alphabetically
		else
			return registry.languages[first].name:lower() < registry.languages[second].name:lower()
		end
	end)
end

--- Returns a reference to a language object with the given proper name (case insensitive).
---
--- @param name string The proper name of the language to get. This should be the human-readable name, like "C++"
--- as opposed to the internal name, like "cpp". This is case insensitive.
---
--- @return Language | nil
function registry.get_language_by_name(name)
	if not name then
		return nil
	end
	for _, language in pairs(registry.languages) do
		if language.name:lower() == name:lower() then
			return language
		end
	end
	return nil
end

return registry
