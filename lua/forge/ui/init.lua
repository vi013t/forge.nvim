local util = require("forge.util")
local f = require("forge.util.fstring")
local registry = require("forge.registry")
local symbols = require("forge.ui.symbols")

-- The public exports of forge-ui
local public = {}

---@alias line_type "language" | "compiler"

---@type { type: line_type, language: string }[]
public.lines = { {}, {}, {}, {} }
for _, language_key in ipairs(registry.language_keys) do
	table.insert(public.lines, { language = registry.languages[language_key].name, type = "language" })
end

local current_line = 0

---@type string[]
public.expanded_languages = {}

-- Centers some text using the global width and height variables of the forge buffer.
--
---@param text string The text to center
--
---@return string centered_text The centered text
local function center(text)
	local shift = math.floor(public.width / 2) - math.floor(text:len() / 2)
	return (' '):rep(shift) .. text
end

local highlight_groups = {}

-- Returns the associated highlight group for a given hex color, or creates and returns a new one if none
-- currently exists.
--
---@param color string The color of the highlight group to get
--
---@return string highlight_group The name of the highlight group corresponding to the given color.
local function get_highlight_group_for_color(color)
	if highlight_groups[color] then return highlight_groups[color] end
	local highlight_group_name = ("ForgeColor%s"):format(color:sub(2))
	highlight_groups[color] = highlight_group_name
	vim.cmd(("highlight %s guifg=%s"):format(highlight_group_name, color))
	return highlight_group_name
end

-- Writes a line of text to the forge buffer.
--
--
---@param text string The line to write
---@param options { alignment?: string, at_beginning?: boolean, colors?: table<string, integer[]> }?
--
---@return nil
local function write_line(text, options)
	if not options then options = {} end
	if options.alignment == "center" then text = center(text) end

	local start
	if options.at_beginning then start = 0 else start = -1 end

	local line = vim.api.nvim_buf_line_count(public.buffer)
	vim.api.nvim_buf_set_lines(public.buffer, start, -1, false, { text })

	if options.colors then
		for color, columns in pairs(options.colors) do
			local highlight_group
			if util.is_hex_color(color) then highlight_group = get_highlight_group_for_color(color)
			else highlight_group = color end
			vim.api.nvim_buf_add_highlight(public.buffer, -1, highlight_group, line, columns[1], columns[2] or #text - 1)
		end
	end

	current_line = current_line + 1
end

-- Returns the text at a give line number in the forge buffer.
--
---@param line_number integer The number of the line to get the text on
--
---@return string? text The text on the line
local function get_line(line_number)
	return vim.api.nvim_buf_get_lines(public.buffer, line_number - 1, line_number, false)[1]
end


-- Draws the compiler info to the screen
--
---@param language language the language to draw the compiler of 
--
---@return nil
local function draw_compiler(language)
	if language.installed_compilers[1] then
		name = language.installed_compilers[1].name
		command = language.installed_compilers[1].command
		write_line(f"       Compiler: $name ($command) ▸", {
			colors = {
				["#00FE00"] = { #"      ", #"      " }, -- TODO: multiple columns for same highlight group
				["#00FF00"] = { #"       Compiler: ", #f"       Compiler: $name" },
				["Comment"] = { #f"       Compiler: $name", #f"       Compiler: $name ($command)" }
			}
		})
	else
		if #language.compilers > 0 then
			write_line("       Compiler: None Installed ▸", {
				colors = {
					["#FF0000"] = { #"      ", #"      " },
					["#990000"] = { #"       Compiler: ", #"       Compiler: None Installed" }
				}
			})
		else
			write_line("       Compiler: Not Supported ▸", {
				colors = {
					["#FFFE00"] = { #"      ", #"      " },
					["#FFFF00"] = { #"       Compiler: ", #"       Compiler: Not Supported" }
				}
			})
		end
	end
end

---@param language language the language to draw the highlighter of
--
---@return nil
local function draw_highlighter(language)
	if language.installed_highlighters[1] then
		name = language.installed_highlighters[1]
		write_line(f"       Highlighter: Treesitter ($name) ▸", {
			colors = {
				["#00FE00"] = { #"      ", #"      " },
				["#00FF00"] = { #"       Highlighter: ", #"       Highlighter: Treesitter" },
				["Comment"] = { #"       Highlighter: Treesitter ", #f"       Highlighter: Treesitter ($name)" }
			}
		})
	else
		treesitters_available = #language.treesitters
		write_line(f"       Highlighter: None Installed ($treesitters_available available) ▸", {
			colors = {
				["#FF0000"] = { #"      ", #"      " },
				["#990000"] = { #"       Highlighter:" , #"       Highlighter: None Installed" },
				["Comment"] = { #"       Highlighter: None Installed ", #f"       Highlighter: None Installed ($treesitters_available available)" }
			}
		})
	end
end

---@param language language
--
---@return nil
local function draw_linter(language)
	if language.installed_linters[1] then
		local linter = language.installed_linters[1]
		write_line(("       Linter: %s (%s) ▸"):format(linter.name, linter.package), {
			colors = {
				["#00FE00"] = { #"      ", #"      " },
				["#00FF00"] = { 18, 19 + #linter.name } ,
				["Comment"] = { 19 + #linter.name, 21 + #linter.package + #linter.name }
			}
		})
	else
		write_line(("       Linter: None Installed (%d available) ▸"):format(#language.lsps), {
			colors = {
				["#FF0000"] = { #"      ", #"      " },
				["#990000"] = { 18, 18 + #"None Installed" },
				["Comment"] = { 19 + #"None Installed", 20 + #("None Installed (%d available)"):format(#language.lsps) }
			}
		})
	end
end

---@return nil
local function draw_formatter(language)
	if language.installed_formatters[1] then
		local formatter = language.installed_formatters[1]
		write_line(("       Formatter: %s (%s) ▸"):format(formatter.name, formatter.package), {
			colors = {
				["#00FE00"] = { #"      ", #"      " },
				["#00FF00"] = { 21, 21 + #formatter.name } ,
				["Comment"] = { 22 + #formatter.name, 24 + #formatter.package + #formatter.name }
			}
		})
	else
		write_line(("       Formatter: None Installed (%d available) ▸"):format(#language.formatters), {
			colors = {
				["#FF0000"] = { #"      ", #"      " },
				["#990000"] = { 21, 21 + #"None Installed" },
				["Comment"] = { 22 + #"None Installed", 23 + #("None Installed (%d available)"):format(#language.formatters) }
			}
		})
	end
end

---@return nil
local function draw_debugger(language)
	if language.installed_debuggers[1] then
		local debugger = language.installed_debuggers[1]
		write_line(("       Debugger: %s (%s) ▸"):format(debugger.name, debugger.package), {
			colors = {
				["#00FE00"] = { #"      ", #"      " },
				["#00FF00"] = { 19, 20 + #debugger.name } ,
				["Comment"] = { 21 + #debugger.name, 23 + #debugger.package + #debugger.name }
			}
		})
	else
		if #language.debuggers > 0 then
			write_line(("       Debugger: None Installed (%d available) ▸"):format(#language.debuggers), {
				colors = {
					["#FF0000"] = { #"      ", #"      " },
					["#990000"] = { 20, 20 + #"None Installed" },
					["Comment"] = { 21 + #"None Installed", 21 + #("None Installed (%d available)"):format(#language.debuggers) }
				}
			})
		else
			write_line("       Debugger: Not Supported ▸", {
				colors = {
					["#FFFF00"] = { #"      ", #"      " },
					["#FFFE00"] = { 20, 20 + #"Not Supported" },
				}
			})
		end
	end
end

---@param language language The language to draw the additional tools of
--
---@return nil
local function draw_additional_tools(language)
	write_line("       Additional Tools: None Installed ▸", { colors = {
		["#00FFFF"] = { 6, 9 },
		["#00FFFE"] = { 28, 28 + #"None Installed" }
	} })
end

---@param language language
local function draw_expanded_language(language)
	if language.name == public.get_language_under_cursor() then
		write_line(("    %s %s ▾   (Press e to collapse, i to install all, or u to uninstall all)"):format(symbols.progress_icons[language.total][language.installed_total], language.name), {
			colors = {
				[symbols.progress_colors[language.total][language.installed_total]] = { 4, 7 }, -- Icon
				["Comment"] = { 11 + #language.name, 77 + #language.name } -- Down arrow
			}
		})
	else
		write_line(("    %s %s ▾"):format(symbols.progress_icons[language.total][language.installed_total], language.name), {
			colors = {
				[symbols.progress_colors[language.total][language.installed_total]] = { 4, 7 }, -- Icon
				["Comment"] = { 11 + #language.name, 12 + #language.name } -- Down arrow
			}
		})
	end
end

-- Draws the languages onto the forge buffer.
local function draw_languages()
	write_line("  Languages")

	for _, key in ipairs(registry.language_keys) do
		local language = registry.languages[key]

		if util.contains(public.expanded_languages, language.name) then
			draw_expanded_language(language)
			draw_compiler(language)
			draw_highlighter(language)
			draw_linter(language)
			draw_formatter(language)
			draw_debugger(language)
			draw_additional_tools(language)
		else
			if language.name == public.get_language_under_cursor() then
				write_line(("    %s %s ▸   (Press e to expand, i to install all, or u to uninstall all)"):format(symbols.progress_icons[language.total][language.installed_total], language.name), {
					colors = {
						[symbols.progress_colors[language.total][language.installed_total]] = { 4, 7 },
						["Comment"] = { 11 + #language.name, 75 + #language.name }
					}
				})
			else
				write_line(("    %s %s ▸"):format(symbols.progress_icons[language.total][language.installed_total], language.name), {
					colors = {
						[symbols.progress_colors[language.total][language.installed_total]] = { 4, 7 },
						["Comment"] = { 11 + #language.name, 12 + #language.name }
					}
				})
			end
		end
	end
end

-- The row that the cursor is on, used to keep the cursor in the same spot when reloading the window.
---@type integer
public.cursor_row = 1

-- Updates the forge buffer.
function public.update_view()
	vim.api.nvim_buf_set_option(public.buffer, 'modifiable', true)
	current_line = 0
	write_line("Forge", { alignment = "center", at_beginning = true })
	write_line("")
	write_line("Expand (e)   Install (i)   Uninstall (u)   Refresh (r)   Filter (f)   Help (?)   Quit (q)", { alignment = "center" })
	draw_languages()
	write_line("")
	vim.fn.cursor({ public.cursor_row, 0 })
	vim.api.nvim_buf_set_option(public.buffer, 'modifiable', false)
end

-- Returns the langauge at the given line number, or `nil` if there is no language at the line
--
---@param line_number integer The line number in the forge buffer to get the language at
--
---@return string? language_name The name of the language found
local function get_language_at_line(line_number)
	local line_text = get_line(line_number)
	if line_text == nil then
		if line_number <= #registry.language_keys + 4 then
			return registry.languages[registry.language_keys[line_number - 4]].name
		else
			return nil
		end
	end
	---@cast line_text string
	local _, _, language_name = line_text:find("([^%s]+)%s+▸")
	if not language_name then _, _, language_name = line_text:find("([^%s]+)%s+▾") end

	-- Check if it's actually a language or just the word "Installed ▾" or something like that
	local language_exists = false
	if language_name ~= nil then
		for _, language in pairs(registry.languages) do
			if language.name == language_name then
				language_exists = true
				break
			end
		end
	end

	if not language_exists then language_name = nil end

	return language_name
end

-- Returns the language that the cursor is under, or `nil` if the cursor is not under a language
---@return string? language_name The name of the language found
function public.get_language_under_cursor()
	return get_language_at_line(public.cursor_row)
end

-- Opens the forge buffer.
function public.open_window()
	public.buffer = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(public.buffer, 'bufhidden', 'wipe')

	local vim_width = vim.api.nvim_get_option("columns")
	local vim_height = vim.api.nvim_get_option("lines")

	public.height = math.ceil(vim_height * 0.8 - 4)
	public.width = math.ceil(vim_width * 0.8)

	local window_options = {
		style = "minimal",
		relative = "editor",
		width = public.width,
		height = public.height,
		row = math.ceil((vim_height - public.height) / 2 - 1),
		col = math.ceil((vim_width - public.width) / 2)
	}

	local mappings = {
		q = "close_window",
		e = "expand",
		j = "move_cursor_down",
		k = "move_cursor_up",
		["<Up>"] = "move_cursor_up",
		["<Down>"] = "move_cursor_down"
	}

	for key, action in pairs(mappings) do
		vim.api.nvim_buf_set_keymap(public.buffer, 'n', key, (":lua require('forge.ui.actions').%s()<CR>"):format(action), {
			nowait = true, noremap = true, silent = true,
		})
	end
	public.window = vim.api.nvim_open_win(public.buffer, true, window_options)
end

return public
