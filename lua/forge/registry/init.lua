local config = require("forge.config")
local parsers = require("nvim-treesitter.parsers")
local linters = require("mason-registry")

local public = {}

public.languages = {
	bash = {
		name = "Bash",
		treesitters = { "bash" },
		compilers = {
			{ command = "bash", name = "Bash" }
		},
		formatters = {
		},
		lsps = {
			{ package = "bash-language-server", name = "Bash Language Server" }
		},
		debuggers = {
			{ package = "bash-debug-adapter", name = "Bash Debug Adapter" }
		},
		additional_tools = {
			{}
		}
	},
	c = {
		name = "C",
		treesitters = { "c", "make" },
		compilers = {
			{ command = "cc", name = "Custom C Compiler" },
			{ command = "gcc", name = "GNU C Compiler" },
			{ command = "tcc", name = "Tiny C Compiler" },
			{ command = "zig", name = "Zig C Compiler" },
			{ command = "clang", name = "Clang Compiler" },
		},
		formatters = {
			{ package = "clang-format", name = "Clang Format" }
		},
		lsps = {
			{ package = "clangd", name = "Clang Daemon" }
		},
		debuggers = {
			{ package = "cpptools", name = "C++ Tools" }
		},
		additional_tools = {
			{ }
		}
	},
	cpp = {
		name = "C++",
		treesitters = { "cpp", "make" },
		compilers = {
			{ command = "cc", name = "Custom C Compiler" },
			{ command = "gcc", name = "GNU C Compiler" },
			{ command = "tcc", name = "Tiny C Compiler" },
			{ command = "zig", name = "Zig C Compiler" },
			{ command = "clang", name = "Clang Compiler" },
		},
		formatters = {
			{ package = "clang-format", name = "Clang Format" }
		},
		lsps = {
			{ package = "clangd", name = "Clang Daemon" }
		},
		debuggers = {
			{ package = "cpptools", name = "C++ Tools" }
		},
		additional_tools = {
			{ }
		}
	},
	csharp = {
		name = "C#",
		treesitters = { "csharp" },
		compilers = {
			{ command = "dotnet", name = ".NET SDK" }
		},
		lsps = {
			{ package = "omnisharp", name = "Omnisharp" }
		},
		debuggers = {
		},
		formatters = {
			{ package = "csharpier", name = "C Sharpier" }
		},
		additional_tools = {
			{}
		}
	},
	go = {
		name = "Go",
		treesitters = { "go", "gomod", "gosum", "gowork" },
		compilers = {
			{ command = "go", name = "Go Compiler" },
		},
		formatters = {
			{ package = "gofumpt", name = "Strict Go Formatter" }
		},
		lsps = {
			{ package = "gopls", name = "Go Programming Language Server" }
		},
		debuggers = {
			{ package = "go-debug-adapter", name = "Go Debug Adapter" }
		},
		additional_tools = {
			{}
		}
	},
	java = {
		name = "Java",
		treesitters = { "java" },
		compilers = {
			{ command = "java", name = "Java Compiler" }
		},
		formatters = {
			{ package = "google-java-format", name = "Google Java Formatter" },
		},
		lsps = {
			{ package = "java-language-server", name = "Java Language Server" },
		},
		debuggers = {
			{ package = "java-debug-adapter", name = "Java Debug Adapter" }
		},
		additional_tools = {
			{}
		}
	},
	javascript = {
		name = "JavaScript",
		treesitters = {
			"javascript",
			"json",
		},
		compilers = {
			{ command = "node", name = "NodeJS" }
		},
		lsps = {
			{ package = "eslint-lsp", name = "EcmaScript Lint Language Server" }
		},
		formatters = {
			{ package = "prettier", name = "Prettier" }
		},
		debuggers = {
			{ package = "js-debug-adapter", name = "JavaScript Debug Adapter" }
		},
		additional_tools = {
			{}
		}
	},
	julia = {
		name = "Julia",
		treesitters = { "julia" },
		compilers = {
			{ command = "julia", name = "Julia Compiler" }
		},
		lsps = {
			{ package = "julia-lsp", name = "Julia Language Server" }
		},
		formatters = {
		},
		debuggers = {

		},
		additional_tools = {
			{}
		}
	},
	kotlin = {
		name = "Kotlin",
		treesitters = { "kotlin" },
		compilers = {
			{ command = "kotlin", name = "Kotlin Compiler" }
		},
		formatters = {
			{ package = "ktlint", name = "Kotlin Linter (with Formatter)" }
		},
		lsps = {
			{ package = "kotlin-language-server", name = "Kotlin Language Server" }
		},
		debuggers = {
			{ package = "kotlin-debug-adapter", name = "Kotlin Debug Adapter" }
		},
		additional_tools = {
			{}
		}
	},
	rust = {
		name = "Rust",
		treesitters = { "rust", "toml" },
		compilers = {
			{ command = "cargo", name = "Cargo" }
		},
		formatters = {
			{ package = "rustfmt", name = "Rust Format" }
		},
		lsps = {
			{ package = "rust-analyzer", name = "Rust Analyzer" }
		},
		debuggers = {},
		additional_tools = {
			{}
		}
	},
	typescript = {
		name = "TypeScript",
		treesitters = {
			"typescript",
			"json"
		},
		compilers = {
			{ command = "tsc", name = "TypeScript Transpiler" }
		},
		lsps = {
			{ package = "typescript-language-server", name = "TypeScript Language Server" }
		},
		formatters = {
			{ package = "prettier", name = "Prettier" }
		},
		debuggers = {

		},
		additional_tools = {
			{}
		}
	},
	zig = {
		name = "Zig",
		treesitters = { "zig" },
		compilers = {
			{ command = "zig", name = "Zig Compiler" }
		},
		formatters = {

		},
		lsps = {
			{ package = "zls", name = "Zig Language Server" }
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
	if config.config.developer_mode then
		print("Refreshing installations...")
		print(("User is on %s"):format(get_os()))
	end
	for _, language_name in ipairs(public.language_keys) do
		local language = public.languages[language_name]
		print(("Checking installations for %s"):format(language.name))

		-- Compiler
		local installed_compilers = {}
		print(language.compilers[1].command)
		for _, compiler in ipairs(language.compilers) do
			if config.config.developer_mode then
				print(("Checking '%s' installation..."):format(compiler.command))
			end
			if command_exists(compiler.command) then
				table.insert(installed_compilers, compiler)
				if config.config.developer_mode then
					print(("Command %s exists!"):format(compiler.command))
				end
			else
				if config.config.developer_mode then
					print(("Command %s doesn't exist!"):format(compiler.command))
				end
			end
		end
		language.installed_compilers = installed_compilers

		-- Highlighter
		local installed_highlighters = {}
		for _, highlighter in ipairs(language.treesitters) do
			if parsers.has_parser(highlighter) then
				table.insert(installed_highlighters, highlighter)
			end
		end
		language.installed_highlighters = installed_highlighters

		-- Linter
		local installed_linters = {}
		for _, linter in ipairs(language.lsps) do
			for _, package in ipairs(linters.get_installed_package_names()) do
				if package == linter.package then
					table.insert(installed_linters, linter)
					break
				end
			end
		end
		language.installed_linters = installed_linters

		-- Formatter 
		local installed_formatters = {}
		for _, formatter in ipairs(language.formatters) do
			for _, package in ipairs(linters.get_installed_package_names()) do
				if package == formatter.package then
					table.insert(installed_formatters, formatter)
					break
				end
			end
		end
		language.installed_formatters = installed_formatters

		-- Debugger
		local installed_debuggers = {}
		for _, debugger in ipairs(language.debuggers) do
			for _, package in ipairs(linters.get_installed_package_names()) do
				if package == debugger.package then
					table.insert(installed_debuggers, debugger)
					break
				end
			end
		end
		language.installed_debuggers = installed_debuggers
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
