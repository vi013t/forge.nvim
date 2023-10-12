local config = require("forge.config")
local parsers = require("nvim-treesitter.parsers")
local linters = require("mason-registry")

---@type { languages: language[], language_keys: string[], refresh_installations: fun(): nil }
local public = {}

---@alias tool { name: string, internal_name: string }
---@alias language { name: string, highlighters: tool[], compilers: tool[], formatters: tool[], debuggers: tool[], linters: tool[], additional_tools: any[], total?: integer, installed_highlighters?: string[], installed_debuggers?: tool[], installed_formatters?: tool[], installed_compilers?: tool[], installed_linters?: tool[], installed_additional_tools?: tool[], installed_total?: integer }

---@type language[]
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
		additional_tools = {
		}
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
		additional_tools = {
		}
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
			{ internal_name = "clangd", name = "Clang Daemon" }
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
			{ internal_name = "csharp", name = "csharp" },
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
		additional_tooks = {
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
			{ internal_name = "html-lsp", name = "HTML Language Server" }
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
		},
		debuggers = {
			{ internal_name = "java-debug-adapter", name = "Java Debug Adapter" }
		},
		additional_tools = {
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
			{ internal_name = "eslint-lsp", name = "EcmaScript Lint Language Server" }
		},
		formatters = {
			{ internal_name = "prettier", name = "Prettier" }
		},
		debuggers = {
			{ internal_name = "js-debug-adapter", name = "JavaScript Debug Adapter" }
		},
		additional_tools = {
		}
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
			{ internal_name = "lua", name = "Lua Compiler" }
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
			{ internal_name = "cargo", name = "Cargo" }
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
	typescript = {
		name = "TypeScript",
		highlighters = {
			{ internal_name = "typescript", name = "TreeSitter" }
		},
		compilers = {
			{ internal_name = "tsc", name = "TypeScript Transpiler" }
		},
		linters = {
			{ internal_name = "typescript-language-server", name = "TypeScript Language Server" }
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
		additional_tools = {}
	}
}

public.language_keys = {}
for key, _ in pairs(public.languages) do
	table.insert(public.language_keys, key)
end

local function get_os()
	if package.config:sub(1, 1) == '\\' then return "windows" else return "unix" end
end

-- Checks whether a shell command can be found
--
---@param command_name string
--
---@return boolean exists whether the command can be found
local function command_exists(command_name)
	if get_os() == "windows" then
		local exit_code = os.execute(("where %s > nul 2>&1"):format(command_name))
		return exit_code == 0
	end

	local exit_code = os.execute(("command -v %s"):format(command_name))
	return exit_code == 0
end

function public.refresh_installations()
	for _, language_name in ipairs(public.language_keys) do
		local language = public.languages[language_name]

		-- Compiler
		local installed_compilers = {}
		for _, compiler in ipairs(language.compilers) do
			if command_exists(compiler.internal_name) then
				table.insert(installed_compilers, compiler)
			end
		end
		language.installed_compilers = installed_compilers

		-- Highlighter
		local installed_highlighters = {}
		for _, highlighter in ipairs(language.highlighters) do
			if parsers.has_parser(highlighter.internal_name) then
				table.insert(installed_highlighters, highlighter)
			end
		end
		language.installed_highlighters = installed_highlighters

		-- Linter
		local installed_linters = {}
		for _, linter in ipairs(language.linters) do
			for _, internal_name in ipairs(linters.get_installed_package_names()) do
				if internal_name == linter.internal_name then
					table.insert(installed_linters, linter)
					break
				end
			end
		end
		language.installed_linters = installed_linters

		-- Formatter 
		local installed_formatters = {}
		for _, formatter in ipairs(language.formatters) do
			for _, internal_name in ipairs(linters.get_installed_package_names()) do
				if internal_name == formatter.internal_name then
					table.insert(installed_formatters, formatter)
					break
				end
			end
		end
		language.installed_formatters = installed_formatters

		-- Debugger
		local installed_debuggers = {}
		for _, debugger in ipairs(language.debuggers) do
			for _, internal_name in ipairs(linters.get_installed_package_names()) do
				if internal_name == debugger.internal_name then
					table.insert(installed_debuggers, debugger)
					break
				end
			end
		end
		language.installed_debuggers = installed_debuggers

		language.installed_additional_tools = {}
	end

end

public.refresh_installations()
for key, _ in pairs(public.languages) do
	local language = public.languages[key]
	language.total = 5

	local actual_installed = 1
	if language.installed_compilers[1] then actual_installed = actual_installed + 1 end
	if language.installed_highlighters[1] then actual_installed = actual_installed + 1 end
	if language.installed_linters[1] then actual_installed = actual_installed + 1 end
	if language.installed_formatters[1] then actual_installed = actual_installed + 1 end
	if language.installed_debuggers[1] then actual_installed = actual_installed + 1 end
	language.installed_total = actual_installed
end

table.sort(public.language_keys, function(first, second)
	return public.languages[first].installed_total > public.languages[second].installed_total
end)

return public
