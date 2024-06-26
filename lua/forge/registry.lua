local os_utils = require("forge.util.os")
local parsers = require("nvim-treesitter.parsers")
local mason_registry = require("mason-registry")

local public = {}

---@alias tool { name: string, internal_name: string }
---
---@class Language
---
---@field name string
---@field compiler_type? string
---
---@field highlighters tool[]
---@field compilers tool[]
---@field formatters tool[]
---@field debuggers tool[]
---@field linters tool[]
---@field additional_tools any[]
---@field total? integer
---
---@field installed_highlighters? string[]
---@field installed_debuggers? tool[]
---@field installed_formatters? tool[]
---@field installed_compilers? tool[]
---@field installed_linters? tool[]
---@field installed_additional_tools? tool[]
---@field installed_total? integer
---
---@field extensions string[]
---@field example_snippet? { text: string, foreground: string }[][]
---@field description? string
---@field icon string
---@field color string

-- NOTE: when making dev changes to the registry, you'll need to delete your lockfile to see the changes.
-- This is located at vim.fn.stdpath("data") .. "/forge.lock", which in most cases for linux is ~/.local/share/nvim/forge.lock

---@type table<string, Language>
public.languages = {
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
		description = [[
			Bash, also known as the Bourne Again SHell, is a Unix shell and command language. It was the default shell on most
			Unix systems, though now many use zsh by default, such as MacOS and Kali Linux. It's a relatively primitive
			scripting language that mainly just serves to act as the primary shell for the system.
		]],
		extensions = { "sh", "bash" },
		icon = "󱆃",
		color = "#89E051",
	},
	c = {
		name = "C",
		compiler_type = "compiler",
		highlighters = {
			{ internal_name = "c", name = "TreeSitter" },
		},
		compilers = {
			{ internal_name = "cc",    name = "Custom C Compiler" },
			{ internal_name = "clang", name = "Clang Compiler" },
			{ internal_name = "gcc",   name = "GNU C Compiler" },
			{ internal_name = "tcc",   name = "Tiny C Compiler" },
			{ internal_name = "zig",   name = "Zig C Compiler" },
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
		description = [[
			C is a statically typed, procedural systems language made in 1972 as an iteration of the B language.
			It has stood the test of time as a popular language for systems programming, and is used in massive
			projects like the Linux kernel, the Python interpreter, and the SQLite database engine. C sacrifices
			safety to give the developer full control and performance.
		]],
		extensions = { "c", "h" },
		icon = "󰙱",
		color = "#599EFF",
	},
	cpp = {
		name = "C++",
		compiler_type = "compiler",
		highlighters = {
			{ internal_name = "cpp", name = "TreeSitter" },
		},
		compilers = {
			{ internal_name = "cc",    name = "Custom C Compiler" },
			{ internal_name = "gcc",   name = "GNU C Compiler" },
			{ internal_name = "tcc",   name = "Tiny C Compiler" },
			{ internal_name = "zig",   name = "Zig C Compiler" },
			{ internal_name = "clang", name = "Clang Compiler" },
		},
		formatters = {
			{ internal_name = "clang-format", name = "Clang Format" },
		},
		linters = {
			{ internal_name = "clangd",  name = "Clang Daemon" },
			{ internal_name = "cpplint", name = "C++ Linter" },
		},
		debuggers = {
			{ internal_name = "cpptools", name = "C++ Tools" },
		},
		additional_tools = {},
		extensions = { "h", "cpp", "hpp", "cxx", "cc", "c++", "hxx", "hh", "h++" },
		description = [[
			C++ is a statically typed object-oriented systems language created in 1983 as an extension of the C language.
			It was originally made to be C with classes, but now has many more features, such as templates, exceptions, and
			operator overloading. C++ is used in many large projects, such as game engines, web browsers, and embedded systems,
			though it's often criticized for its complexity.
		]],
		icon = "󰙲",
		color = "#F34B7D",
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
				description = "Development enhancements for C# in Neovim",
				name = "C# Tools for Neovim",
			},
		},
		description = [[
			C# is a statically typed, object-oriented programming language created by Microsoft in 2000
			along with the .NET framework. It is used for creating Windows applications, web applications,
			and games using the Unity game engine. C# is a popular language for enterprise development.
		]],
		extensions = { "cs" },
		icon = "󰌛",
		color = "#596706",
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
		extensions = { "ex", "exs" },
		icon = "",
		color = "#A074C4",
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
				description =
				"Everything you need to develop Go in Neovim - including preproject setup, async jobs, improved highlighting, test coverage, and more.",
				name = "Go Tools for Neovim",
			},
			{
				type = "plugin",
				internal_name = "crusj/structure-go.nvim",
				description = "A symbol list and outline for Go",
				name = "Go Symbol Outline",
			},
		},
		extensions = { "go" },
		icon = "󰟓",
		color = "#519ABA",
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
		extensions = { "hs" },
		icon = "",
		color = "#A074C4",
	},
	html = {
		name = "HTML",
		highlighters = {
			{ internal_name = "html", name = "TreeSitter" },
		},
		compilers = { -- TODO: I would like to think of a clever way to cleanly wrap lines
			none_available_reason =
			"HTML is a markup language, meaning it just describes the structure of a web page. As such, it doesn't have a compiler or interpreter; It's interpreted by a web browser.",
		},
		formatters = {
			{ internal_name = "prettier", name = "Prettier" },
		},
		linters = {
			{ internal_name = "html-lsp",                    name = "HTML Language Server" },
			{ internal_name = "emmet-language-server",       name = "Emmet Language Server" },
			{ internal_name = "emmet-ls",                    name = "Emmet Language Server" },
			{ internal_name = "tailwindcss-language-server", name = "Tailwind CSS Language Server" },
			{ internal_name = "rustywind",                   name = "Rusty Wind" },
		},
		debuggers = {},
		additional_tools = {
			{
				type = "plugin",
				internal_name = "roobert/tailwindcss-colorizer-cmp.nvim",
				description = "Tailwind CSS completion addon for nvim-cmp",
				name = "Tailwind CSS colorizer & autocomplete",
			},
		},
		extensions = { "html", "htm" },
		example_snippet = {
			{
				{ text = "<",         foreground = "@operator" },
				{ text = "!DOCTYPE ", foreground = "@tag" },
				{ text = "html",      foreground = "@tag" },
				{ text = ">",         foreground = "@operator" },
			},
			{
				{ text = "<",    foreground = "@operator" },
				{ text = "html", foreground = "@tag" },
				{ text = ">",    foreground = "@operator" },
			},
			{
				{ text = "<",    foreground = "@operator" },
				{ text = "head", foreground = "@tag" },
				{ text = ">",    foreground = "@operator" },
			},
			{
				{ text = "    <",   foreground = "@operator" },
				{ text = "meta ",   foreground = "@tag" },
				{ text = "charset", foreground = "@attribute" },
				{ text = "=",       foreground = "@operator" },
				{ text = '"UTF-8"', foreground = "@string" },
				{ text = "/>",      foreground = "@operator" },
			},
			{
				{ text = "    <",              foreground = "@operator" },
				{ text = "meta ",              foreground = "@tag" },
				{ text = "author",             foreground = "@attribute" },
				{ text = "=",                  foreground = "@operator" },
				{ text = '"Violet Iapalucci"', foreground = "@string" },
				{ text = "/>",                 foreground = "@operator" },
			},
			{ text = " " },
			{
				{ text = "    <",                       foreground = "@operator" },
				{ text = "link ",                       foreground = "@tag" },
				{ text = "rel",                         foreground = "@attribute" },
				{ text = "=",                           foreground = "@operator" },
				{ text = '"icon" ',                     foreground = "@string" },
				{ text = "href",                        foreground = "@attribute" },
				{ text = "=",                           foreground = "@operator" },
				{ text = '"assets/images/favicon.ico"', foreground = "@string" },
				{ text = "/>",                          foreground = "@operator" },
			},
			{ text = " " },
			{
				{ text = "    <",           foreground = "@operator" },
				{ text = "title",           foreground = "@tag" },
				{ text = ">",               foreground = "@operator" },
				{ text = "My epic webpage", foreground = "Normal" },
				{ text = "</",              foreground = "@operator" },
				{ text = "title",           foreground = "@tag" },
				{ text = ">",               foreground = "@operator" },
			},
			{
				{ text = "</",   foreground = "@operator" },
				{ text = "head", foreground = "@tag" },
				{ text = ">",    foreground = "@operator" },
			},
			{
				{ text = "<",    foreground = "@operator" },
				{ text = "body", foreground = "@tag" },
				{ text = ">",    foreground = "@operator" },
			},
			{
				{ text = "    <",         foreground = "@operator" },
				{ text = "h1",            foreground = "@tag" },
				{ text = ">",             foreground = "@operator" },
				{ text = "Hello, world!", foreground = "Normal" },
				{ text = "</",            foreground = "@operator" },
				{ text = "h1",            foreground = "@tag" },
				{ text = ">",             foreground = "@operator" },
			},
			{
				{ text = "</",   foreground = "@operator" },
				{ text = "body", foreground = "@tag" },
				{ text = ">",    foreground = "@operator" },
			},
			{
				{ text = "</",   foreground = "@operator" },
				{ text = "html", foreground = "@tag" },
				{ text = ">",    foreground = "@operator" },
			},
		},
		description = [[
			HTML (HyperText Markup Language) is the standard markup language for documents designed to be displayed in a web browser.
			It is often used in conjunction with CSS and JavaScript to create web pages and web applications. HTML is not a programming
			language in the traditional sense, but rather a markup language that defines the structure of some content.
		]],
		icon = "",
		color = "#E44D26",
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
			{ internal_name = "java-language-server",   name = "Java Language Server" },
			{ internal_name = "gradle-language-server", name = "Gradle Language Server" },
		},
		debuggers = {
			{ internal_name = "java-debug-adapter", name = "Java Debug Adapter" },
		},
		additional_tools = {
			{
				type = "mason",
				internal_name = "vscode-java-decompiler",
				description = "Java Decompiler",
				name = "Java Decompiler",
			},
			{
				type = "plugin",
				internal_name = "simaxme/java.nvim",
				description = "Refactoring tools such as renaming symbols, renaming files, and moving files.",
				name = "Java Refactorer",
			},
		},
		description = [[
			Java is a statically typed object-oriented programming language that compiles to bytecode which runs on the
			Java Virtual Machine (JVM). Java was created to be a write once, run anywhere language, and has been used in
			games, web applications, and enterprise applications. Java is one of the most popular programming languages
			in the industry today.
		]],
		extensions = { "java" },
		icon = "",
		color = "#CC3E44",
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
			{ internal_name = "js-debug-adapter",     name = "JavaScript Debug Adapter" },
			{ internal_name = "chrome-debug-adapter", name = "Chrome Debug Adapter" },
		},
		additional_tools = {},
		extensions = { "js", "jsx" },
		description = [[
			JavaScript is a programming language designed for creating interactive websites and web applications. It's a
			high-level language that is often used in conjunction with HTML and CSS to create dynamic websites. JavaScript
			started as a website-only language, but today is used for backend development, mobile apps, desktop apps, and more.
		]],
		icon = "",
		color = "#F1F134",
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
		extensions = { "json" },
		description = [[
			JSON, which stands for "JavaScript Object Notation", is a data serialization format. It is not a "programming language"
			in the sense that it does not execute instructions or code, but rather it simply stores structured data. JSON is often
			used to transfer data and is commonly used in web development, due to its ease of use with JavaScript.
		]],
		icon = "",
		color = "#CBCB41",
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
		extensions = { "jl" },
		icon = "",
		color = "#A270BA",
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
		extensions = { "kt" },
		icon = "",
		color = "#7F52FF",
	},
	lua = {
		name = "Lua",
		compiler_type = "interpreter",
		highlighters = {
			{ internal_name = "lua", name = "TreeSitter" },
		},
		compilers = {
			{ internal_name = "lua",    name = "Lua Compiler" },
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
				internal_name = "folke/neodev.nvim",
				description = "Support for Neovim development in Lua",
				name = "Neodev",
			},
		},
		extensions = { "lua" },
		description = [[
			Lua is a dynamically typed and highly embeddable scripting language created in 1993. It gained
			popularity in the game development space, being used in games such as World of Warcraft and
			Roblox. Today, Lua is a popular configuration language for applications like Neovim, Wezterm,
			and AwesomeWM, while still being widely used for game development.
		]],
		icon = "",
		color = "#51A0CF",
	},
	markdown = {
		name = "Markdown",
		highlighters = {
			{ internal_name = "markdown", name = "TreeSitter" },
		},
		compilers = {},
		linters = {
			{ internal_name = "markdownlint", name = "Markdown Linter" },
		},
		formatters = {},
		debuggers = {},
		additional_tools = {},
		icon = "󰍔",
		color = "#FFFFFF",
		description = [[
			Markdown is a simple syntax for creating documents with basic formatting, like bold text, italics, and
			bulleted lists. It's often used for documentation, README files, and note taking. Markdown is generally
			not interpreted or compiled into another form, but rather is read and rendered by a program that understands
			the syntax, like a web browser or a markdown viewer.
		]],
		extensions = { "md" },
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
		extensions = { "ml", "mli" },
		icon = "",
		color = "#E37933",
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
		},
		debuggers = {
			{ internal_name = "debugpy", name = "DebugPY" },
		},
		additional_tools = {
			{
				type = "plugin",
				internal_name = "AckslD/swenv.nvim",
				description = "Quickly switch Python virtual environments without restarting",
				name = "Swenv",
			},
		},
		extensions = { "py" },
		description = [[
			Python is a high-level, general purpose programming language created in 1991. It is known for
			being a very easy language to learn and use, while also having an extremely powerful ecosystem
			of libraries and tools. Python is used for web development, data analysis, machine learning, and
			more, and is one of the most sought-after languages.
		]],
		icon = "",
		color = "#FFBC03",
	},
	r = {
		name = "R",
		compiler_type = "interpreter",
		compilers = {
			{ internal_name = "R",       name = "R Interpreter" },
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
		extensions = { "r" },
		icon = "󰟔",
		color = "#2266BA",
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
		extensions = { "rb" },
		icon = "",
		color = "#701516",
	},
	rust = {
		name = "Rust",
		description = [[
			Rust is a memory safe, performant, and secure systems language designed to create fast, secure applications. Rust is known
			for it's memory safety, compile-time checking, advanced type system, and zero-cost abstractions. Released (stable) in 2015,
			Rust today is used for systems programming, TUI applications, GUI applications, websites, and more.
		]],
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
				description =
				"Up-to-date support for Rust tooling in Neovim, including integration with Syntastic, Tagbar, Playpen, and more, and enables auto-formatting with rustfmt on save without an external formatter.",
				name = "Rust Vim Support",
			},
		},
		example_snippet = {
			{
				{ text = "fn ",    foreground = "@keyword.function" },
				{ text = "main",   foreground = "@function" },
				{ text = "() -> ", foreground = "@punctuation" },
				{ text = "Box",    foreground = "@type" },
				{ text = "<",      foreground = "@punctuation" },
				{ text = "dyn ",   foreground = "@keyword" },
				{ text = "Error",  foreground = "@type" },
				{ text = "> {",    foreground = "@punctuation" },
			},
			{
				{ text = "    let ", foreground = "@keyword" }, -- TODO: allow configurable tab sizing
				{ text = "mut ",     foreground = "@keyword" },
				{ text = "x",        foreground = "@variable" },
				{ text = " = ",      foreground = "@punctuation" },
				{ text = "5",        foreground = "@number" },
				{ text = ";",        foreground = "@punctuation" },
			},
			{
				{ text = "    let ", foreground = "@keyword" },
				{ text = "mut ",     foreground = "@keyword" },
				{ text = "y",        foreground = "@variable" },
				{ text = " = &",     foreground = "@punctuation" },
				{ text = "mut ",     foreground = "@keyword" },
				{ text = "x",        foreground = "@variable" },
				{ text = ";",        foreground = "@punctuation" },
			},
			{
				{ text = "}", foreground = "@punctuation" },
			},
		},
		extensions = { "rs" },
		icon = "",
		color = "#DEA584",
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
		description = [[
			Svelte is a component-based front-end web framework. Unlike most other web frameworks, Svelte compiles
			to native JavaScript at build time, rather than interpreting the code at runtime. This results in smaller
			bundle sizes and faster load times. Furthermore, Svelte is extremely simple to use and fast to iterate with.
		]],
		extensions = { "svelte" },
		icon = "",
		color = "#FF3E00",
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
		extensions = { "swift" },
		icon = "",
		color = "#E37933",
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
		description = [[
			Teal is a typed dialect of Lua that compiles to Lua. It is designed to build off of Lua's strengths
			of simplicity and readability, while also making the language more safe and easier to debug at compile-time.
			There are similar projects like TS2Lua, which compiles TypeScript to Lua, but Teal is the closest to Lua.
		]],
		extensions = { "tl" },
		icon = "⚆",
		color = "#007171",
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
		description = [[
			TOML, which stands for "Tom's Obvious, Minimal Language", is a simple configuration file format that is
			designed to be easy to read and write. It is less verbose than JSON, and is often used for configuration,
			such as in the Cargo.toml file for Rust projects, or for Python projects.
		]],
		icon = "",
		color = "#FFFFFF",
		extensions = { "toml" },
	},
	typescript = {
		name = "TypeScript",
		compiler_type = "transpiler",
		highlighters = {
			{ internal_name = "typescript", name = "TypeScript TreeSitter" },
			{ internal_name = "tsx",        name = "TypeScript + React TreeSitter" },
		},
		compilers = {
			{ internal_name = "tsc", name = "TypeScript Transpiler" },
		},
		linters = {
			{ internal_name = "typescript-language-server", name = "TypeScript Language Server" },
			{ internal_name = "angular-language-server",    name = "Angular Language Server" },
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
				description = "Show TypeScript types as virtual text with `// ^?` comments",
			},
		},
		description = [[
			TypeScript is a statically typed version of JavaScript, designed to make web development
			easier and more maintainable with static types, allowing more mistakes to be caught at
			compile-time.
		]],
		extensions = { "ts", "tsx" },
		icon = "󰛦",
		color = "#519ABA",
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
		extensions = { "yaml", "yml" },
		additional_tools = {
			{
				type = "plugin",
				internal_name = "someone-stole-my-name/yaml-companion.nvim",
				description = "Get, set and autodetect YAML schemas in your buffers.",
				name = "YAML Companion",
			},
			{
				type = "plugin",
				internal_name = "cuducos/yaml.nvim",
				name = "YAML Path Tools",
				description = "Show, yank, search, and generate YAML paths.",
			},
		},
		icon = "",
		color = "#6D8086",
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
		description = [[
			Zig is a statically typed compiled systems language designed for creating extremely performant applications.
			One of Zig's core design goals is to never allocate on the heap unless explicitly asked to, and utilizes
			custom allocators to handle memory management. Zig is designed to be simple, fast, and safe, and is quickly
			gaining traction.
		]],
		extensions = { "zig" },
		icon = "",
		color = "#F69A1B",
	},
}

function public.refresh_installations()
	public.generate_language_keys()

	for _, language_name in ipairs(public.language_keys) do
		local language = public.languages[language_name]

		-- Compiler
		local installed_compilers = Table({})
		for _, compiler in ipairs(language.compilers) do
			if os_utils.command_exists(compiler.internal_name) then
				installed_compilers:insert(compiler)
			end
		end
		language.installed_compilers = installed_compilers

		-- Highlighter
		local installed_highlighters = Table({})
		for _, highlighter in ipairs(language.highlighters) do
			if parsers.has_parser(highlighter.internal_name) then
				installed_highlighters:insert(highlighter)
			end
		end
		language.installed_highlighters = installed_highlighters

		-- Linter
		local installed_linters = Table({})
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
		local installed_formatters = Table({})
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
		local installed_debuggers = Table({})
		for _, debugger in ipairs(language.debuggers) do
			for _, internal_name in ipairs(mason_registry.get_installed_package_names()) do
				if internal_name == debugger.internal_name then
					installed_debuggers:insert(debugger)
					break
				end
			end
		end
		language.installed_debuggers = installed_debuggers

		language.installed_additional_tools = Table({})
	end

	-- Get the actual number of installatinons
	for key, _ in pairs(public.languages) do
		local language = public.languages[key]

		language.total = 1
		if #language.compilers > 0 then
			language.total = language.total + 1
		end
		if #language.highlighters > 0 then
			language.total = language.total + 1
		end
		if #language.linters > 0 then
			language.total = language.total + 1
		end
		if #language.formatters > 0 then
			language.total = language.total + 1
		end
		if #language.debuggers > 0 then
			language.total = language.total + 1
		end

		local actual_installed = 1
		if language.installed_compilers[1] then
			actual_installed = actual_installed + 1
		end
		if language.installed_highlighters[1] then
			actual_installed = actual_installed + 1
		end
		if language.installed_linters[1] then
			actual_installed = actual_installed + 1
		end
		if language.installed_formatters[1] then
			actual_installed = actual_installed + 1
		end
		if language.installed_additional_tools[1] then
			actual_installed = actual_installed + 1
		end

		language.installed_total = actual_installed
	end

	public.sort_languages()
end

-- Refreshes the `installed_total` field of a language to accurately reflect the number of tool types installed for it.
--
---@param language Language
--
---@return nil
function public.refresh_installed_totals(language)
	local actual_installed = 1
	if language.installed_compilers[1] then
		actual_installed = actual_installed + 1
	end
	if language.installed_highlighters[1] then
		actual_installed = actual_installed + 1
	end
	if language.installed_linters[1] then
		actual_installed = actual_installed + 1
	end
	if language.installed_formatters[1] then
		actual_installed = actual_installed + 1
	end
	if language.installed_additional_tools[1] then
		actual_installed = actual_installed + 1
	end
	language.installed_total = actual_installed
end

function public.generate_language_keys()
	public.language_keys = Table({})
	for key, _ in pairs(public.languages) do
		public.language_keys:insert(key)
	end
end

function public.sort_languages()
	public.language_keys:sort(function(first, second)
		local first_percent =
			math.floor(100 * ((public.languages[first].installed_total - 1) / (public.languages[first].total - 1)))
		local second_percent =
			math.floor(100 * ((public.languages[second].installed_total - 1) / (public.languages[second].total - 1)))

		if first_percent > second_percent then
			return true
		elseif first_percent < second_percent then
			return false
		else
			return public.languages[first].name:lower() < public.languages[second].name:lower()
		end
	end)
end

function public.get_language_by_name(name)
	if not name then
		return nil
	end
	for _, language in pairs(public.languages) do
		if language.name:lower() == name:lower() then
			return language
		end
	end
	return nil
end

function public.get_language_icon(language_name)
	local has_devicons, devicons = pcall(require, "nvim-web-devicons")
	if has_devicons then
		local language = public.get_language_by_name(language_name)
		if not language then
			return nil
		end
		return devicons.get_icon(
			"example." .. language.extensions[1],
			language.extensions[1],
			{ default = true, strict = true }
		)
	end
	return nil
end

return public
