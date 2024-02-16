local util = require("forge.util")
local registry = require("forge.registry")
local symbols = require("forge.ui.symbols")

-- The public exports of forge-ui
---@type table<any, any>
local public = Table({})

---@alias line_type "language" | "compiler"

---@type { type: line_type, language: string, name?: string, internal_name?: string }[]
public.lines = Table({ {}, {}, {}, {} }) -- 4 lines before the first language

-- Resets the lines list
local function reset_lines()
	public.lines = Table({ {}, {}, {}, {} }) -- 4 lines before the first language
	for _, language_key in ipairs(registry.language_keys) do
		public.lines:insert({ language = registry.languages[language_key].name, type = "language" })
	end
	public.lines:insert({})
end

---@type string[]
public.expanded_languages = Table({})

---@type string[]
public.expanded_compilers = Table({})

---@type string[]
public.expanded_linters = Table({})

---@type string[]
public.expanded_highlighters = Table({})

---@type string[]
public.expanded_formatters = Table({})

---@type string[]
public.expanded_debuggers = Table({})

---@type string[]
public.expanded_additional_tools = Table({})

---@type table<string, string>
local highlight_groups = Table({})

-- Returns the associated highlight group for a given hex color, or creates and returns a new one if none
-- currently exists.
--
---@param options { foreground?: string, background?: string, italicize?: boolean, bold?: boolean }?
--
---@return string highlight_group The name of the highlight group corresponding to the given color.
local function get_highlight_group_for_color(options)
	if not options then
		options = {}
	end

	-- Generate highlight group name
	local name = "ForgeColor"
	if options.foreground then
		name = name .. "Fg" .. options.foreground:sub(2)
	end
	if options.background then
		name = name .. "Bg" .. options.background:sub(2)
	end
	if options.italicize then
		name = name .. "Italics"
	end
	if options.bold then
		name = name .. "Bold"
	end

	-- Check if it already exists
	if highlight_groups[name] then
		return highlight_groups[name]
	end
	highlight_groups[name] = name

	-- Foreground
	local guifg = nil
	if options.foreground then
		guifg = "guifg=" .. options.foreground
	end

	-- Background
	local guibg = nil
	if options.background then
		guibg = "guibg=" .. options.background
	end

	-- Word effects (italics, bold, etc.)
	local gui = "gui="
	if options.italicize then
		gui = gui .. "italic"
		if options.bold then
			gui = gui .. ",bold"
		end
	elseif options.bold then
		gui = gui .. "bold"
	end

	-- Generate Vim command
	local highlight_command = ("highlight %s"):format(name)
	if guifg then
		highlight_command = highlight_command .. " " .. guifg
	end
	if guibg then
		highlight_command = highlight_command .. " " .. guibg
	end
	if gui ~= "gui=" then
		highlight_command = highlight_command .. " " .. gui
	end
	vim.cmd(highlight_command)

	return name
end

local is_first_draw_call = true

-- Writes a line at the end of the forge buffer
--
---@param option_list { text: string, foreground?: string, background?: string, italicize?: boolean, bold?: boolean }[]
---@param is_centered? boolean
--
---@return nil
local function write_line(option_list, is_centered)
	local text = ""
	for _, options in ipairs(option_list) do
		text = text .. options.text
	end

	local shift = 0
	if is_centered then
		shift = math.floor(public.width / 2) - math.floor(text:len() / 2)
		text = (" "):rep(shift) .. text
	end

	local line = vim.api.nvim_buf_line_count(public.buffer)
	if is_first_draw_call then
		line = 0
	end

	local start = -1
	if is_first_draw_call then
		start = 0
	end
	is_first_draw_call = false
	vim.api.nvim_buf_set_lines(public.buffer, start, -1, false, { text })

	text = ""
	for _, options in ipairs(option_list) do
		text = text .. options.text
		if options.foreground or options.background then
			local highlight_group
			if util.is_hex_color(options.foreground) or util.is_hex_color(options.background) then
				highlight_group = get_highlight_group_for_color(options)
			else
				highlight_group = options.foreground or options.background
			end
			---@cast highlight_group string
			vim.api.nvim_buf_add_highlight(
				public.buffer,
				-1,
				highlight_group,
				line,
				#text - #options.text + shift,
				#text + shift
			)
		end
	end
end

-- Draws the compiler info to the screen
--
---@param language language the language to draw the compiler of
---@param tool_name "compilers" | "highlighters" | "linters" | "formatters" | "debuggers" | "additional_tools"
--
---@return nil
local function draw_tool(language, tool_name)
	local write_buffer = Table({ { text = "    " } })

	local snake_tool_name = tool_name
	if tool_name == "compilers" then
		if not language.compiler_type then
			return
		end
		snake_tool_name = language.compiler_type .. "s"
	end

	local proper_tool_name = util.snake_case_to_title_case(snake_tool_name)
	if tool_name ~= "additional_tools" then
		proper_tool_name = proper_tool_name:sub(1, -2)
	end

	if tool_name == "additional_tools" then
		write_buffer:insert({ text = "└ ", foreground = "Comment" })
	else
		write_buffer:insert({ text = "│ ", foreground = "Comment" })
	end

	-- Icon, compiler name, compiler command
	if language["installed_" .. tool_name][1] then
		write_buffer:insert({ text = "", foreground = "#00FF00" })
		write_buffer:insert({ text = " " .. proper_tool_name .. ": " })
		write_buffer:insert({ text = language["installed_" .. tool_name][1].name, foreground = "#00FF00" })
		write_buffer:insert({
			text = " (" .. language["installed_" .. tool_name][1].internal_name .. ")",
			foreground = "Comment",
		})
	elseif #language[tool_name] > 0 then
		write_buffer:insert({ text = "", foreground = "#FF0000" })
		write_buffer:insert({ text = " " .. proper_tool_name .. ": " })
		write_buffer:insert({ text = "None Installed", foreground = "#FF0000" })
		write_buffer:insert({ text = " (" .. #language[tool_name] .. " available)", foreground = "Comment" })
	else
		write_buffer:insert({ text = "", foreground = "#FFFF00" })
		write_buffer:insert({ text = " " .. proper_tool_name .. ": " })
		write_buffer:insert({ text = "None Available", foreground = "#FFFF00" })
	end

	-- Arrow
	if public["expanded_" .. tool_name]:contains(language.name) then
		write_buffer:insert({ text = " ▾" })
	else
		write_buffer:insert({ text = " ▸" })
	end

	-- Prompt
	if
		public.lines[public.cursor_row].type == tool_name:sub(1, -2)
		and public.lines[public.cursor_row].language == language.name
	then
		write_buffer:insert({ text = "   (Press ", foreground = "Comment" })
		write_buffer:insert({ text = "e", foreground = "#AAAA77" })
		write_buffer:insert({ text = " to ", foreground = "Comment" })
		write_buffer:insert({ text = "expand", foreground = "#AAAA77" })
		write_buffer:insert({ text = ", ", foreground = "Comment" })
		write_buffer:insert({ text = "i", foreground = "#77AAAA" })
		write_buffer:insert({ text = " to ", foreground = "Comment" })
		write_buffer:insert({ text = "install recommended", foreground = "#77AAAA" })
		write_buffer:insert({ text = ", or ", foreground = "Comment" })
		write_buffer:insert({ text = "u", foreground = "#AA77AA" })
		write_buffer:insert({ text = " to ", foreground = "Comment" })
		write_buffer:insert({ text = "uninstall all", foreground = "#AA77AA" })
		write_buffer:insert({ text = ")", foreground = "Comment" })
	end

	write_line(write_buffer)

	-- Expanded tool
	if public["expanded_" .. tool_name]:contains(language.name) then
		for index, tool in ipairs(language[tool_name]) do
			write_buffer = Table({})
			local bars = "    │ │"
			if tool_name == "additional_tools" then
				bars = "      │"
			end
			if index == #language[tool_name] then
				bars = "    │ └"
				if tool_name == "additional_tools" then
					bars = "      └"
				end
			end
			local line = public.lines[public.cursor_row]

			-- Tool is currently installing
			if
				public.currently_installing
				and public.currently_installing.language == language.name
				and public.currently_installing.type == tool_name .. "_listing"
			then
				write_buffer:insert({ text = bars, foreground = "Comment" })
				write_buffer:insert({ text = "  ", foreground = "#00AAFF" })
				write_buffer:insert({ text = tool.name, foreground = "#00AAFF" })
				write_buffer:insert({ text = " (" .. tool.internal_name .. ") ", foreground = "Comment" })
				write_buffer:insert({ text = "   (Installing...)", foreground = "#00AAFF" })

			-- Tool is installed already
			elseif table.contains(language["installed_" .. tool_name], tool) then
				write_buffer:insert({ text = bars, foreground = "Comment" })
				write_buffer:insert({ text = "  ", foreground = "#00FF00" })
				write_buffer:insert({ text = tool.name, foreground = "#00FF00" })
				write_buffer:insert({ text = " (" .. tool.internal_name .. ") ", foreground = "Comment" })

				-- Prompt
				if
					line.type == tool_name:sub(1, -2) .. "_listing"
					and line.language == language.name
					and line.name == tool.name
				then
					write_buffer:insert({ text = "   (Press ", foreground = "Comment" })
					write_buffer:insert({ text = "u", foreground = "#AA77AA" })
					write_buffer:insert({ text = " to ", foreground = "Comment" })
					write_buffer:insert({ text = "uninstall", foreground = "#AA77AA" })
					write_buffer:insert({ text = ")", foreground = "Comment" })
				end

			-- Tool is not installed
			else
				write_buffer:insert({ text = bars, foreground = "Comment" })
				write_buffer:insert({ text = "  ", foreground = "#FF0000" })
				write_buffer:insert({ text = tool.name, foreground = "#FF0000" })
				write_buffer:insert({ text = " (" .. tool.internal_name .. ") ", foreground = "Comment" })

				-- Prompt
				if
					line.type == tool_name:sub(1, -2) .. "_listing"
					and line.language == language.name
					and line.name == tool.name
				then
					write_buffer:insert({ text = "   (Press ", foreground = "Comment" })
					write_buffer:insert({ text = "i", foreground = "#77AAAA" })
					write_buffer:insert({ text = " to ", foreground = "Comment" })
					write_buffer:insert({ text = "install", foreground = "#77AAAA" })
					write_buffer:insert({ text = ")", foreground = "Comment" })
				end
			end

			-- Write out the buffer
			write_line(write_buffer)
		end

		-- None available
		if #language[tool_name] < 1 then
			write_buffer = Table({})
			if tool_name == "additional_tools" then
				write_buffer:insert({ text = "      └ ", foreground = "Comment" })
			else
				write_buffer:insert({ text = "    │ └ ", foreground = "Comment" })
			end

			write_buffer:insert({ text = " ", foreground = "#FFFF00" })
			write_buffer:insert({ text = "Currently, there " })

			if tool_name == "additional_tools" then
				write_buffer:insert({ text = "are" })
			else
				write_buffer:insert({ text = "is" })
			end

			write_buffer:insert({ text = " no " })

			if tool_name == "additional_tools" then
				write_buffer:insert({ text = "additional tools" })
			else
				write_buffer:insert({ text = tool_name:sub(1, -2) })
			end

			write_buffer:insert({ text = " available for " })
			write_buffer:insert({ text = language.name })
			write_line(write_buffer)
		end
	end
end

-- Draws a language name that's expanded
--
---@param language language The language name to draw
--
---@return nil
local function draw_expanded_language(language)
	if language.name == public.get_language_under_cursor() then
		write_line({
			{
				text = "    " .. symbols.progress_icons[language.total][language.installed_total],
				foreground = symbols.progress_colors[language.total][language.installed_total],
			},
			{ text = " " .. language.name },
			{ text = " ▾", foreground = "Comment" },
			{ text = "   (Press ", foreground = "Comment" },
			{ text = "e", foreground = "#AAAA77" },
			{ text = " to ", foreground = "Comment" },
			{ text = "collapse", foreground = "#AAAA77" },
			{ text = ", ", foreground = "Comment" },
			{ text = "i", foreground = "#77AAAA" },
			{ text = " to ", foreground = "Comment" },
			{ text = "install all", foreground = "#77AAAA" },
			{ text = ", or ", foreground = "Comment" },
			{ text = "u", foreground = "#AA77AA" },
			{ text = " to ", foreground = "Comment" },
			{ text = "uninstall all", foreground = "#AA77AA" },
			{ text = ")", foreground = "Comment" },
		})
	else
		write_line({
			{ text = "    " },
			{
				text = symbols.progress_icons[language.total][language.installed_total],
				foreground = symbols.progress_colors[language.total][language.installed_total],
			},
			{ text = " " },
			{ text = language.name },
			{ text = " ▾", foreground = "Comment" },
		})
	end
end

-- Draws the languages onto the forge buffer.
--
---@return nil
local function draw_languages()
	local languages_line = Table({})
	languages_line:insert({ text = "  Languages" })
	write_line(languages_line)

	for _, key in ipairs(registry.language_keys) do
		local language = registry.languages[key]

		if public.expanded_languages:contains(language.name) then
			draw_expanded_language(language)
			draw_tool(language, "compilers")
			draw_tool(language, "highlighters")
			draw_tool(language, "linters")
			draw_tool(language, "formatters")
			draw_tool(language, "debuggers")
			draw_tool(language, "additional_tools")
		else
			if language.name == public.get_language_under_cursor() then
				write_line({
					{
						text = "    " .. symbols.progress_icons[language.total][language.installed_total],
						foreground = symbols.progress_colors[language.total][language.installed_total],
					},
					{ text = " " .. language.name },
					{ text = " ▸", foreground = "Comment" },
					{ text = "   (Press ", foreground = "Comment" },
					{ text = "e", foreground = "#AAAA77" },
					{ text = " to ", foreground = "Comment" },
					{ text = "expand", foreground = "#AAAA77" },
					{ text = ", ", foreground = "Comment" },
					{ text = "i", foreground = "#77AAAA" },
					{ text = " to ", foreground = "Comment" },
					{ text = "install all", foreground = "#77AAAA" },
					{ text = ", or ", foreground = "Comment" },
					{ text = "u", foreground = "#AA77AA" },
					{ text = " to ", foreground = "Comment" },
					{ text = "uninstall all", foreground = "#AA77AA" },
					{ text = ")", foreground = "Comment" },
				})
			else
				write_line({
					{ text = "    " },
					{
						text = symbols.progress_icons[language.total][language.installed_total],
						foreground = symbols.progress_colors[language.total][language.installed_total],
					},
					{ text = " " },
					{ text = language.name },
					{ text = " ▸", foreground = "Comment" },
				})
			end
		end
	end
end

-- The row that the cursor is on, used to keep the cursor in the same spot when reloading the window.
---@type integer
public.cursor_row = 1

-- Updates the forge buffer.
--
---@return nil
function public.update_view()
	is_first_draw_call = true
	vim.api.nvim_buf_set_option(public.buffer, "modifiable", true)
	write_line({ { text = " Forge ", background = "#CC99FF", foreground = "#000000" } }, true)
	write_line({ { text = "" } })
	write_line({
		{ text = " Expand (e) ", background = "#99FFFF", foreground = "#000000" },
		{ text = "   " },
		{ text = " Install (i) ", background = "#99FFFF", foreground = "#000000" },
		{ text = "   " },
		{ text = " Uninstall (u) ", background = "#99FFFF", foreground = "#000000" },
		{ text = "   " },
		{ text = " Prefer (p) ", background = "#99FFFF", foreground = "#000000" },
		{ text = "   " },
		{ text = " Options (o) ", background = "#99FFFF", foreground = "#000000" },
		{ text = "   " },
		{ text = " Refresh (r) ", background = "#99FFFF", foreground = "#000000" },
		{ text = "   " },
		{ text = " Quit (q) ", background = "#99FFFF", foreground = "#000000" },
	}, true)
	draw_languages()
	write_line({ { text = "" } })
	vim.fn.cursor({ public.cursor_row, 0 })
	vim.api.nvim_buf_set_option(public.buffer, "modifiable", false)
end

-- Returns the langauge at the given line number, or `nil` if there is no language at the line
--
---@param line_number integer The line number in the forge buffer to get the language at
--
---@return string? language_name The name of the language found
local function get_language_at_line(line_number)
	if public.lines[line_number].type == "language" then
		return public.lines[line_number].language
	else
		return nil
	end
end

-- Returns the language that the cursor is under, or `nil` if the cursor is not under a language
--
---@return string? language_name The name of the language found
function public.get_language_under_cursor()
	return get_language_at_line(public.cursor_row)
end

-- Opens the forge buffer.
--
---@return nil
function public.open_window()
	reset_lines()
	public.buffer = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(public.buffer, "bufhidden", "wipe")

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
		col = math.ceil((vim_width - public.width) / 2),
	}

	local mappings = {
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
	}

	for key, action in pairs(mappings) do
		vim.api.nvim_buf_set_keymap(
			public.buffer,
			"n",
			key,
			(":lua require('forge.ui.actions').%s()<CR>"):format(action),
			{
				nowait = true,
				noremap = true,
				silent = true,
			}
		)
	end
	public.window = vim.api.nvim_open_win(public.buffer, true, window_options)
end

return public
