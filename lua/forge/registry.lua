local os_utils = require("forge.util.os")
local parsers = require("nvim-treesitter.parsers")
local mason_registry = require("mason-registry")

local public = Table {}

---@alias tool { name: string, internal_name: string }
---@alias language { name: string, highlighters: tool[], compilers: tool[], formatters: tool[], debuggers: tool[], linters: tool[], additional_tools: any[], total?: integer, installed_highlighters?: string[], installed_debuggers?: tool[], installed_formatters?: tool[], installed_compilers?: tool[], installed_linters?: tool[], installed_additional_tools?: tool[], installed_total?: integer }

---@type table<string, language>
public.languages = {
	bash = {
		name = "Bash",
		highlighters = {
			{ internal_name = "bash", name = "TreeSitter" },
		},
		compilers = {
			{ internal_name = "bash", name = "Bash" }
		},
		formatters = {
		},
		linters = {
			{ internal_name = "bash-language-server", name = "Bash Language Server" }
		},
		debuggers = {
			{ internal_name = "bash-debug-adapter", name = "Bash Debug Adapter" }
		},
		additional_tools = {}
	},
	c = {
		name = "C",
		highlighters = {
			{ internal_name = "c", name = "TreeSitter" },
		},
		compilers = {
			{ internal_name = "cc", name = "Custom C Compiler" },
			{ internal_name = "gcc", name = "GNU C Compiler" },
			{ internal_name = "tcc", name = "Tiny C Compiler" },
			{ internal_name = "zig", name = "Zig C Compiler" },
			{ internal_name = "clang", name = "Clang Compiler" },
		},
		formatters = {
			{ internal_name = "clang-format", name = "Clang Format" }
		},
		linters = {
			{ internal_name = "clangd", name = "Clang Daemon" }
		},
		debuggers = {
			{ internal_name = "cpptools", name = "C++ Tools" }
		},
		additional_tools = {}
	},
	cpp = {
		name = "C++",
		highlighters = {
			{ internal_name = "cpp", name = "TreeSitter" },
		},
		compilers = {
			{ internal_name = "cc", name = "Custom C Compiler" },
			{ internal_name = "gcc", name = "GNU C Compiler" },
			{ internal_name = "tcc", name = "Tiny C Compiler" },
			{ internal_name = "zig", name = "Zig C Compiler" },
			{ internal_name = "clang", name = "Clang Compiler" },
		},
		formatters = {
			{ internal_name = "clang-format", name = "Clang Format" }
		},
		linters = {
			{ internal_name = "clangd", name = "Clang Daemon" },
			{ internal_name = "cpplint", name = "C++ Linter" }
		},
		debuggers = {
			{ internal_name = "cpptools", name = "C++ Tools" }
		},
		additional_tools = {
		}
	},
	csharp = {
		name = "C#",
		highlighters = {
			{ internal_name = "c_sharp", name = "TreeSitter" },
		},
		compilers = {
			{ internal_name = "dotnet", name = ".NET SDK" }
		},
		linters = {
			{ internal_name = "omnisharp", name = "Omnisharp" }
		},
		debuggers = {
		},
		formatters = {
			{ internal_name = "csharpier", name = "C Sharpier" }
		},
		additional_tools = {
		}
	},
	elixir = {
		name = "Elixir",
		compilers = {
			{ internal_name = "elixir", name = "Elixir Compiler" }
		},
		highlighters = {
			{ internal_name = "elixir", name = "TreeSitter" }
		},
		linters = {
			{ internal_name = "elixir-ls", name = "Elixir Language Server" }
		},
		debuggers = {},
		formatters = {},
		additional_tools = {}
	},
	go = {
		name = "Go",
		highlighters = {
			{ internal_name = "go", name = "TreeSitter" }
		},
		compilers = {
			{ internal_name = "go", name = "Go Compiler" },
		},
		formatters = {
			{ internal_name = "gofumpt", name = "Strict Go Formatter" }
		},
		linters = {
			{ internal_name = "gopls", name = "Go Programming Language Server" }
		},
		debuggers = {
			{ internal_name = "go-debug-adapter", name = "Go Debug Adapter" }
		},
		additional_tools = {
		}
	},
	haskell = {
		name = "Haskell",
		highlighters = {
			{ internal_name = "haskell", name = "Haskell" }
		},
		compilers = {
			{ internal_name = "haskell", name = "Haskell" }
		},
		linters = {
			{ internal_name = "haskell-language-server", name = "Haskell Language Server" }
		},
		debuggers = {
			{ internal_name = "haskell-debug-adapter", name = "Haskell Debug Adapter" }
		},
		formatters = {},
		additional_tools = {
		}
	},
	html = {
		name = "HTML",
		highlighters = {
			{ internal_name = "html", name = "TreeSitter" }
		},
		compilers = {},
		formatters = {
			{ internal_name = "prettier", name = "Prettier" }
		},
		linters = {
			{ internal_name = "html-lsp", name = "HTML Language Server" },
			{ internal_name = "emmet-language-server", name = "Emmet Language Server" },
			{ internal_name = "emmet-ls", name = "Emmet Language Server" },
			{ internal_name = "tailwindcss-language-server", name = "Tailwind CSS Language Server" },
			{ internal_name = "rustywind", name = "Rusty Wind"}
		},
		debuggers = {
		},
		additional_tools = {
			{
				type = "plugin",
				internal_name = "roobert/tailwindcss-colorizer-cmp.nvim",
				description = "Tailwind CSS completion addon for nvim-cmp",
				name = "Tailwind CSS colorizer & autocomplete"
			}
		}
	},
	java = {
		name = "Java",
		highlighters = {
			{ internal_name = "java", name = "TreeSitter" }
		},
		compilers = {
			{ internal_name = "java", name = "Java Compiler" }
		},
		formatters = {
			{ internal_name = "google-java-format", name = "Google Java Formatter" },
		},
		linters = {
			{ internal_name = "java-language-server", name = "Java Language Server" },
			{ internal_name = "gradle-language-server", name = "Gradle Language Server" },
		},
		debuggers = {
			{ internal_name = "java-debug-adapter", name = "Java Debug Adapter" }
		},
		additional_tools = {
			{ internal_name = "vscode-java-decompiler", name = "Java Decompiler", type = "mason" }
		}
	},
	javascript = {
		name = "JavaScript",
		highlighters = {
			{ internal_name = "javascript", name = "TreeSitter" }
		},
		compilers = {
			{ internal_name = "node", name = "NodeJS" }
		},
		linters = {
			{ internal_name = "eslint", name = "EcmaScript Lint Language Server" }
		},
		formatters = {
			{ internal_name = "prettier", name = "Prettier" }
		},
		debuggers = {
			{ internal_name = "js-debug-adapter", name = "JavaScript Debug Adapter" },
			{ internal_name = "chrome-debug-adapter", name = "Chrome Debug Adapter" }
		},
		additional_tools = {
		}
	},
	json = {
		name = "JSON",
		highlighters = {
			{ internal_name = "json", name = "TreeSitter" },
		},
		compilers = {},
		linters = {
			{ internal_name = "json-lsp", name = "JSON Language Server" }
		},
		formatters = {
			{ internal_name = "prettier", name = "Prettier" }
		},
		debuggers = {},
		additional_tools = {}
	},
	julia = {
		name = "Julia",
		highlighters = {
			{ internal_name = "julia", name = "TreeSitter" }
		},
		compilers = {
			{ internal_name = "julia", name = "Julia Compiler" }
		},
		linters = {
			{ internal_name = "julia-lsp", name = "Julia Language Server" }
		},
		formatters = {
		},
		debuggers = {

		},
		additional_tools = {
		}
	},
	kotlin = {
		name = "Kotlin",
		highlighters = {
			{ internal_name = "kotlin", name = "TreeSitter" }
		},
		compilers = {
			{ internal_name = "kotlin", name = "Kotlin Compiler" }
		},
		formatters = {
			{ internal_name = "ktlint", name = "Kotlin Linter (with Formatter)" }
		},
		linters = {
			{ internal_name = "kotlin-language-server", name = "Kotlin Language Server" }
		},
		debuggers = {
			{ internal_name = "kotlin-debug-adapter", name = "Kotlin Debug Adapter" }
		},
		additional_tools = {
		}
	},
	lua = {
		name = "Lua",
		highlighters = {
			{ internal_name = "lua", name = "TreeSitter" }
		},
		compilers = {
			{ internal_name = "lua", name = "Lua Compiler" },
			{ internal_name = "luajit", name = "Lua Just-in-Time Compiler" }
		},
		linters = {
			{ internal_name = "lua-language-server", name = "Lua Language Server" }
		},
		formatters = {
			{ internal_name = "stylua", name = "Stylua" }
		},
		debuggers = {
		},
		additional_tools = {
			{
				type = "plugin",
				internal_name = "folke/neodev.nvim",
				description = "Support for Neovim development in Lua",
				name = "Neodev"
			}
		}
	},
	ocaml = {
		name = "OCaml",
		highlighters = {
			{ internal_name = "ocaml", name = "TreeSitter" }
		},
		compilers = {
			{ internal_name = "ocaml", name = "OCaml Compiler" }
		},
		linters = {
			{ internal_name = "ocaml-lsp", name = "OCaml Language Server" }
		},
		formatters = {
			{ internal_name = "ocamlformat", name = "OCaml Format" }
		},
		debuggers = {
		},
		additional_tools = {
		}
	},
	python = {
		name = "Python",
		highlighters = {
			{ internal_name = "python", name = "TreeSitter" }
		},
		compilers = {
			{ internal_name = "python", name = "Python Interpreter" }
		},
		linters = {
			{ internal_name = "pyright", name = "Pyright" }
		},
		formatters = {
			{ internal_name = "black", name = "Black PEP8 Formatter" }
		},
		debuggers = {
			{ internal_name = "debugpy", name = "DebugPY" }
		},
		additional_tools = {
			{
				type = "plugin",
				internal_name = "AcksID/swenv.nvim",
				description = "Quickly switch Python virtual environments without restarting",
				name = "Swenv"
			}
		}
	},
	r = {
		name = "R",
		compilers = {
			{ internal_name = "R", name = "R Interpreter" },
			{ internal_name = "Rscript", name = "R-Script" }
		},
		highlighters = {
			{ internal_name = "r", name = "TreeSitter" }
		},
		linters = {
			{ internal_name = "r-languageserver", name = "R Language Server" }
		},
		formatters = {},
		debuggers = {},
		additional_tools = {}
	},
	ruby = {
		name = "Ruby",
		highlighters = {
			{ internal_name = "ruby", name = "TreeSitter" }
		},
		compilers = {
			{ internal_name = "ruby", name = "Ruby Interpreter" }
		},
		linters = {
			{ internal_name = "ruby-lsp", name = "Ruby Language Server" }
		},
		formatters = {
			{ internal_name = "rubyfmt", name = "Ruby Formatter" }
		},
		debuggers = {},
		additional_tools = {
		}
	},
	rust = {
		name = "Rust",
		highlighters = {
			{ internal_name = "rust", name = "TreeSitter" }
		},
		compilers = {
			{
				internal_name = "cargo",
				name = "Cargo",
				unix_install = "curl --proto '=https' --tlsv1.3 https://sh.rustup.rs -sSf | sh",
				windows_install = "choco install rustup.install",
				unix_uninstall = "rustup self uninstall",
				windows_uninstall = "rustup self uninstall"
			}
		},
		formatters = {
			{ internal_name = "rustfmt", name = "Rust Format" }
		},
		linters = {
			{ internal_name = "rust-analyzer", name = "Rust Analyzer" }
		},
		debuggers = {},
		additional_tools = {
			{
				type = "plugin",
				internal_name = "rust-lang/rust.vim",
				description = "Up-to-date support for Rust tooling in Neovim, including integration with Syntastic, Tagbar, Playpen, and more, and enables auto-formatting with rustfmt on save without an external formatter.",
				name = "Rust Vim Support"
			}
		}
	},
	svelte = {
		name = "Svelte",
		compilers = {
			{ internal_name = "npm", name = "Node Package Manager" }
		},
		highlighters = {
			{ internal_name = "svelte", name = "TreeSitter" },
		},
		linters = {
			{ internal_name = "svelte-language-server", name = "Svelte Language Server" }
		},
		formatters = {
			{ internal_name = "prettier", name = "Prettier" }
		},
		debuggers = {},
		additional_tools = {}
	},
	swift = {
		name = "Swift",
		highlighters = {
			{ internal_name = "swift", name = "TreeSitter" }
		},
		compilers = {
			{ internal_name = "swift", name = "Swift Compiler" }
		},
		linters = {
		},
		formatters = {},
		debuggers = {},
		additional_tools = {
		}
	},
	teal = {
		name = "Teal",
		compilers = {
			{ internal_name = "tl", name = "Teal Transpiler" }
		},
		highlighters = {
			{ internal_name = "teal", name = "TreeSitter" }
		},
		linters = {
			{ internal_name = "teal-language-server", name = "Teal Language Server" }
		},
		formatters = {},
		debuggers = {},
		additional_tools = {}
	},
	typescript = {
		name = "TypeScript",
		highlighters = {
			{ internal_name = "typescript", name = "TreeSitter" }
		},
		compilers = {
			{ internal_name = "tsc", name = "TypeScript Transpiler" }
		},
		linters = {
			{ internal_name = "typescript-language-server", name = "TypeScript Language Server" },
			{ internal_name = "angular-language-server", name = "Angular Language Server" }
		},
		formatters = {
			{ internal_name = "prettier", name = "Prettier" }
		},
		debuggers = {

		},
		additional_tools = {
		}
	},
	v = {
		name = "V",
		highlighters = {
			{ internal_name = "v", name = "TreeSitter" }
		},
		compilers = {
			{ internal_name = "v", name = "V Compiler" }
		},
		linters = {
			{ internal_name = "vls", name = "V Language Server" }
		},
		formatters = {
		},
		debuggers = {

		},
		additional_tools = {
		}
	},
	zig = {
		name = "Zig",
		highlighters = {
			{ internal_name = "zig", name = "TreeSitter" }
		},
		compilers = {
			{ internal_name = "zig", name = "Zig Compiler" }
		},
		formatters = {

		},
		linters = {
			{ internal_name = "zls", name = "Zig Language Server" }
		},
		debuggers = {},
		additional_tools = {
			{ internal_name = "NTBBloodbath/zig-tools.nvim", name = "Zig Tools for Neovim" }
		}
	}
}

function public.refresh_installations()
	public.before_refresh()

	for _, language_name in ipairs(public.language_keys) do
		local language = public.languages[language_name]

		-- Compiler
		local installed_compilers = Table {}
		for _, compiler in ipairs(language.compilers) do
			if os_utils.command_exists(compiler.internal_name) then
				installed_compilers:insert(compiler)
			end
		end
		language.installed_compilers = installed_compilers

		-- Highlighter
		local installed_highlighters = Table {}
		for _, highlighter in ipairs(language.highlighters) do
			if parsers.has_parser(highlighter.internal_name) then
				installed_highlighters:insert(highlighter)
			end
		end
		language.installed_highlighters = installed_highlighters

		-- Linter
		local installed_linters = Table {}
		for _, linter in ipairs(language.linters) do
			for _, internal_name in ipairs(mason_registry.get_installed_package_names()) do
				if internal_name == linter.internal_name then
					installed_linters:insert(linter)
					break
				end
			end
		end
		language.installed_linters = installed_linters

		-- Formatter 
		local installed_formatters = Table {}
		for _, formatter in ipairs(language.formatters) do
			for _, internal_name in ipairs(mason_registry.get_installed_package_names()) do
				if internal_name == formatter.internal_name then
					installed_formatters:insert(formatter)
					break
				end
			end
		end
		language.installed_formatters = installed_formatters

		-- Debugger
		local installed_debuggers = Table {}
		for _, debugger in ipairs(language.debuggers) do
			for _, internal_name in ipairs(mason_registry.get_installed_package_names()) do
				if internal_name == debugger.internal_name then
					installed_debuggers:insert(debugger)
					break
				end
			end
		end
		language.installed_debuggers = installed_debuggers

		language.installed_additional_tools = Table {}
	end

	-- Get the actual number of installatinons
	for key, _ in pairs(public.languages) do
		local language = public.languages[key]

		language.total = 1
		if #language.compilers > 0 then language.total = language.total + 1 end
		if #language.highlighters > 0 then language.total = language.total + 1 end
		if #language.linters > 0 then language.total = language.total + 1 end
		if #language.formatters > 0 then language.total = language.total + 1 end
		if #language.debuggers > 0 then language.total = language.total + 1 end

		local actual_installed = 1
		if language.installed_compilers[1] then actual_installed = actual_installed + 1 end
		if language.installed_highlighters[1] then actual_installed = actual_installed + 1 end
		if language.installed_linters[1] then actual_installed = actual_installed + 1 end
		if language.installed_formatters[1] then actual_installed = actual_installed + 1 end
		if language.installed_debuggers[1] then actual_installed = actual_installed + 1 end

		language.installed_total = actual_installed
	end

	public.after_refresh()

end

---@param language language
function public.refresh_installed_totals(language)
	local actual_installed = 1
	if language.installed_compilers[1] then actual_installed = actual_installed + 1 end
	if language.installed_highlighters[1] then actual_installed = actual_installed + 1 end
	if language.installed_linters[1] then actual_installed = actual_installed + 1 end
	if language.installed_formatters[1] then actual_installed = actual_installed + 1 end
	if language.installed_debuggers[1] then actual_installed = actual_installed + 1 end
	language.installed_total = actual_installed
end

function public.before_refresh()
	public.language_keys = Table {}
	for key, _ in pairs(public.languages) do
		public.language_keys:insert(key)
	end
end

function public.after_refresh()
	public.language_keys:sort(function(first, second)
		local first_percent = math.floor(100 * ((public.languages[first].installed_total - 1) / (public.languages[first].total - 1)))
		local second_percent = math.floor(100 * ((public.languages[second].installed_total - 1) / (public.languages[second].total - 1)))

		if first_percent > second_percent then return true
		elseif first_percent < second_percent then return false
		else return public.languages[first].name:lower() < public.languages[second].name:lower() end
	end)
end

return public
