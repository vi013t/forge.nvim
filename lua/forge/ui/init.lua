local util = require("forge.util")
local registry = require("forge.tools.registry")
local config = require("forge.config")

-- The public exports of forge.ui
---@type table<any, any>
local ui = {}

local function progress(total, amount)
	if amount > total then
		error(("Error getting progress icon/color: Total (%d) is less than amount (%d)."):format(total, amount))
	end

	local color
	local icon
	if total <= 5 then
		color = config.colors().progress[total + 1][amount + 1]
		icon = config.icons().progress[total + 1][amount + 1]
	else
		color = config.colors().progress[6][math.floor(1 + 5 * ((amount + 1) / (total + 1)))]
		icon = config.icons().progress[6][math.floor(1 + 5 * ((amount + 1) / (total + 1)))]
	end

	return color, icon
end

---@alias line_type "language" | "compiler"

---@type { type: line_type, language: string, name?: string, internal_name?: string, tool?: string, entry?: { name: string, module: string, default_config: string, internal_name: string } }[]
ui.lines = Table({ {}, {}, {}, {}, {}, {}, {}, {}, {}, {} }) -- 10 lines before the first language

---@type number | nil
ui.refresh_percentage = nil

-- Resets the lines list
function ui.reset_lines()
	ui.lines = Table({ {}, {}, {}, {}, {} }) -- 5 lines before the first language

	-- Global Tools
	for _, global_tool_key in ipairs(registry.global_tool_keys) do
		ui.lines:insert({ type = "global_tool", tool = global_tool_key })
		if ui.expanded_global_tools:contains(global_tool_key) then
			for _, entry in ipairs(registry.global_tools[global_tool_key].entries) do
				ui.lines:insert({ type = "global_tool_listing", tool = global_tool_key, entry = entry })
			end
		end
	end

	-- Blank & "Language" lines
	ui.lines:insert({})
	ui.lines:insert({})

	-- Languages
	for _, language_key in ipairs(registry.language_keys) do
		local language_name = registry.languages[language_key].name
		ui.lines:insert({ language = language_name, type = "language" })

		-- Expanded languages & tools
		if ui.expanded_languages:contains(language_name) then
			for _, tool in ipairs({ "compiler", "highlighter", "linter", "formatter", "debugger", "additional_tools" }) do
				-- Main tool line (unexpanded)
				ui.lines:insert({ type = tool, language = language_name })

				-- Get the name of the "plural" tool
				local plural_tool = tool .. "s"
				if tool == "additional_tools" then
					plural_tool = tool
				end

				---@type Language
				local language = nil
				for _, registry_language in pairs(registry.languages) do
					if registry_language.name == language_name then
						language = registry_language
						break
					end
				end

				-- Expanded tool
				if ui["expanded_" .. plural_tool]:contains(language_name) then
					for _, language_tool in ipairs(language[plural_tool]) do
						ui.lines:insert({
							type = tool .. "_listing",
							language = language_name,
							name = language_tool.name,
							internal_name = language_tool.internal_name,
							tool = language_tool,
						})
					end

					-- "None supported" additional line
					if #language[plural_tool] == 0 then
						ui.lines:insert({})
					end
				end
			end
		end
	end
	ui.lines:insert({})
end

--- The list of languages that are currently "expanded" meaning their tools are visible.
--- This is a list of the languages "proper names", i.e., the name youd get from something
--- like "registry.languages.c.name".
---
---@type string[]
ui.expanded_languages = Table({})

---@type string[]
ui.expanded_compilers = Table({})

---@type string[]
ui.expanded_linters = Table({})

---@type string[]
ui.expanded_highlighters = Table({})

---@type string[]
ui.expanded_formatters = Table({})

---@type string[]
ui.expanded_debuggers = Table({})

---@type string[]
ui.expanded_additional_tools = Table({})

---@type string[]
ui.expanded_global_tools = Table({})

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
---
---@param option_list { text: string, foreground?: string, background?: string, italicize?: boolean, bold?: boolean }[] A list of text segments, which each can have their own color and styles. The foreground can be a hex color, or the name of a highlight group.
---@param is_centered? boolean whether to center the text in the line instead of left-aligning it
---
---@return nil
local function write_line(option_list, is_centered)
	-- Text
	local text = ""
	for _, options in ipairs(option_list) do
		text = text .. options.text
	end

	-- Alignment
	local shift = 0
	if is_centered then
		shift = math.floor(ui.width / 2) - math.floor(vim.fn.strdisplaywidth(text) / 2)
		text = (" "):rep(shift) .. text
	end

	-- Line number
	local line = vim.api.nvim_buf_line_count(ui.buffer)
	if is_first_draw_call then
		line = 0
	end

	-- Column number
	local start = -1
	if is_first_draw_call then
		start = 0
	end
	is_first_draw_call = false

	-- Write the line
	vim.api.nvim_buf_set_lines(ui.buffer, start, -1, false, { text })

	-- Highlighting (colors, italics, bold, etc.)
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

			-- Add the highlight
			vim.api.nvim_buf_add_highlight(
				ui.buffer, -- Buffer
				-1, -- Namespace ID
				highlight_group, -- Highlight group
				line, -- Line
				#text - #options.text + shift, -- Start column
				#text + shift -- End column
			)
		end
	end
end

-- Draws a tool onto the forge buffer.
--
---@param language Language the language to draw the tool of
---@param tool_name "compilers" | "highlighters" | "linters" | "formatters" | "debuggers" | "additional_tools" The tool to draw
--
---@return nil
local function draw_tool(language, tool_name)
	local write_buffer = Table({ { text = "    " } })

	local snake_tool_name = tool_name
	if tool_name == "compilers" then
		local compiler_type = language.compiler_type
		if not compiler_type then
			compiler_type = "compiler"
		end
		snake_tool_name = compiler_type .. "s"
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
	if tool_name ~= "additional_tools" and language["installed_" .. tool_name][1] then
		write_buffer:insert({ text = config.icons().installed, foreground = config.colors().installed })
		write_buffer:insert({ text = " " .. proper_tool_name .. ": " })
		write_buffer:insert({
			text = language["installed_" .. tool_name][1].name,
			foreground = config.colors().installed,
		})
		write_buffer:insert({
			text = " (" .. language["installed_" .. tool_name][1].internal_name .. ")",
			foreground = "Comment",
		})

	-- Additional Tools
	elseif tool_name == "additional_tools" and #language[tool_name] > 0 then
		local color, icon = progress(#language.additional_tools, #language.installed_additional_tools)
		write_buffer:insert({ text = icon, foreground = color })
		write_buffer:insert({ text = " " .. proper_tool_name .. ": " })
		write_buffer:insert({
			text = ("%d"):format(#language.installed_additional_tools) .. " installed",
			foreground = color,
		})
		local more_text = ""
		if #language.installed_additional_tools > 0 then
			more_text = " more"
		end
		write_buffer:insert({
			text = " ("
				.. (#language.additional_tools - #language.installed_additional_tools)
				.. more_text
				.. " available)",
			foreground = "Comment",
		})

	-- Not additional tools, but availble installations
	elseif #language[tool_name] > 0 then
		write_buffer:insert({ text = config.icons().not_installed, foreground = config.colors().not_installed })
		write_buffer:insert({ text = " " .. proper_tool_name .. ": " })
		write_buffer:insert({ text = "None Installed", foreground = config.colors().not_installed })
		write_buffer:insert({ text = " (" .. #language[tool_name] .. " available)", foreground = "Comment" })

	-- None available
	else
		write_buffer:insert({ text = config.icons().none_available, foreground = config.colors().none_available })
		write_buffer:insert({ text = " " .. proper_tool_name .. ": " })
		write_buffer:insert({ text = "None Available", foreground = config.colors().none_available })
	end

	local is_expanded = ui["expanded_" .. tool_name]:contains(language.name)

	-- Arrow
	if is_expanded then
		write_buffer:insert({ text = " " .. config.icons().down_arrow })
	else
		write_buffer:insert({ text = " " .. config.icons().right_arrow })
	end

	local stubbed_name = tool_name:sub(1, -2)
	if tool_name == "additional_tools" then
		stubbed_name = tool_name:sub(1, -1)
	end

	-- Prompt
	if ui.lines[ui.cursor_row].type == stubbed_name and ui.lines[ui.cursor_row].language == language.name then
		write_buffer:insert({ text = "   (Press ", foreground = "Comment" })
		write_buffer:insert({ text = "e", foreground = "#AAAA77" })
		write_buffer:insert({ text = " to ", foreground = "Comment" })
		if is_expanded then
			write_buffer:insert({ text = "collapse", foreground = "#AAAA77" })
		else
			write_buffer:insert({ text = "expand", foreground = "#AAAA77" })
		end
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
	if ui["expanded_" .. tool_name]:contains(language.name) then
		for index, tool in ipairs(language[tool_name]) do
			-- Initialization
			write_buffer = Table({})
			local line = ui.lines[ui.cursor_row]

			-- Get indentationbars
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

			-- Add symbols to additional tools' internal names
			local internal_name = tool.internal_name
			if tool_name == "additional_tools" then
				internal_name = config.icons()[tool.type] .. " " .. internal_name
			end

			-- Check if the tool is installed
			local tool_is_installed = false
			do
				for _, language_tool in ipairs(language["installed_" .. tool_name]) do
					if language_tool.internal_name == tool.internal_name then
						tool_is_installed = true
					end
				end
			end

			-- Tool is currently installing
			if
				ui.currently_installing
				and ui.currently_installing.language == language.name
				and ui.currently_installing.type == tool_name .. "_listing"
			then
				write_buffer:insert({ text = bars, foreground = "Comment" })
				write_buffer:insert({ text = "  ", foreground = "#00AAFF" })
				write_buffer:insert({ text = tool.name, foreground = "#00AAFF" })
				write_buffer:insert({ text = " (" .. internal_name .. ") ", foreground = "Comment" })
				write_buffer:insert({
					text = "   (Installing...)",
					foreground = "#00AAFF",
				})

			-- Tool is installed already
			elseif tool_is_installed then
				write_buffer:insert({ text = bars, foreground = "Comment" })
				write_buffer:insert({
					text = " " .. config.icons().installed .. " ",
					foreground = config.colors().installed,
				})
				write_buffer:insert({ text = tool.name, foreground = config.colors().installed })
				write_buffer:insert({ text = " (" .. internal_name .. ") ", foreground = "Comment" })

				-- Prompt
				if
					line.type == stubbed_name .. "_listing"
					and line.language == language.name
					and line.name == tool.name
				then
					write_buffer:insert({ text = "   (Press ", foreground = "Comment" })
					write_buffer:insert({ text = "u", foreground = "#AA77AA" })
					write_buffer:insert({ text = " to ", foreground = "Comment" })
					write_buffer:insert({ text = "uninstall", foreground = "#AA77AA" })
					if tool_name == "additional_tools" then
						write_buffer:insert({ text = " or ", foreground = "Comment" })
						write_buffer:insert({ text = "c", foreground = "#AA7777" })
						write_buffer:insert({ text = " to ", foreground = "Comment" })
						write_buffer:insert({ text = "configure", foreground = "#AA7777" })
					end
					write_buffer:insert({ text = ")", foreground = "Comment" })
				end

			-- Tool is not installed
			else
				write_buffer:insert({ text = bars, foreground = "Comment" })
				write_buffer:insert({
					text = " " .. config.icons().not_installed .. " ",
					foreground = config.colors().not_installed,
				})
				write_buffer:insert({ text = tool.name, foreground = config.colors().not_installed })
				write_buffer:insert({ text = " (" .. internal_name .. ") ", foreground = "Comment" })

				-- Prompt
				if
					line.type == stubbed_name .. "_listing"
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

			write_buffer:insert({
				text = config.icons().none_available .. " ",
				foreground = config.colors().none_available,
			})
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
			write_buffer:insert({ text = ". " })

			if language[tool_name].none_available_reason then
				write_buffer:insert({ text = language[tool_name].none_available_reason })
			end

			write_line(write_buffer)
		end
	end
end

-- Draws a language name that's expanded.
---
---@param language Language The language name to draw
---
---@return nil
local function draw_expanded_language(language)
	-- Cursor is on this language - add prompt
	if language.name == ui.get_language_under_cursor() then
		write_line({
			{
				text = "    " .. config.icons().progress[language.total][language.installed_total],
				foreground = config.colors().progress[language.total][language.installed_total],
			},
			{ text = "  " .. language.name },
			{ text = " " .. config.icons().down_arrow, foreground = "Comment" },
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

	-- Cursor is not on this language - no prompt
	else
		write_line({
			{ text = "    " },
			{
				text = config.icons().progress[language.total][language.installed_total],
				foreground = config.colors().progress[language.total][language.installed_total],
			},
			{ text = "  " },
			{ text = language.name },
			{ text = " " .. config.icons().down_arrow, foreground = "Comment" },
		})
	end
end

-- Draws the language list onto the forge buffer.
--
---@return nil
local function draw_languages()
	local languages_line = Table({})
	languages_line:insert({ text = "  Languages ", bold = true })
	languages_line:insert({ text = ("(%s supported)"):format(#registry.language_keys), foreground = "Comment" })
	if ui.refresh_percentage ~= nil then
		languages_line:insert({
			text = ("    Refreshing... (%s%%)"):format(ui.refresh_percentage),
			foreground = "Comment",
		})
	end
	write_line(languages_line)

	local language_index = 0
	for _, key in ipairs(registry.language_keys) do
		language_index = language_index + 1
		local language = registry.languages[key]

		if ui.expanded_languages:contains(language.name) then
			draw_expanded_language(language)
			draw_tool(language, "compilers")
			draw_tool(language, "highlighters")
			draw_tool(language, "linters")
			draw_tool(language, "formatters")
			draw_tool(language, "debuggers")
			draw_tool(language, "additional_tools")
		else
			if language.name == ui.get_language_under_cursor() then
				local line_after_language = {
					{
						text = "    " .. config.icons().progress[language.total][language.installed_total],
						foreground = config.colors().progress[language.total][language.installed_total],
					},
					{ text = "  " .. language.name },
					{ text = " " .. config.icons().right_arrow, foreground = "Comment" },
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
				}

				if ui.current_description_lines then
					local description_line_index = language_index - 2
					if ui.current_description_lines[description_line_index] then
						local offset = -language.name:len() + 27
						table.insert(
							line_after_language,
							{ text = (" "):rep(offset) .. ui.current_description_lines[description_line_index] }
						)
					end
				end

				write_line(line_after_language)
			else
				---@type { text: string, foreground?: string, background?: string, italicize?: boolean, bold?: boolean }[]
				local post_line = {
					{ text = "    " },
					{
						text = config.icons().progress[language.total][language.installed_total],
						foreground = config.colors().progress[language.total][language.installed_total],
					},
					{ text = "  " },
					{ text = language.name },
					{ text = " " .. config.icons().right_arrow, foreground = "Comment" },
				}

				write_line(post_line)
			end
		end
	end
end

local function draw_global_tools()
	for _, global_tool_key in ipairs(registry.global_tool_keys) do
		local global_tool = registry.global_tools[global_tool_key]
		local color, icon = progress(#global_tool.entries, global_tool.installed_entries)
		local line = Table({
			{ text = "    " .. icon .. "  ", foreground = color },
			{ text = registry.global_tools[global_tool_key].name },
		})
		if ui.lines[ui.cursor_row].type == "global_tool" and ui.lines[ui.cursor_row].tool == global_tool_key then
			line:insert({ text = "   (Press ", foreground = "Comment" })
			line:insert({ text = "e", foreground = "#AAAA77" })
			line:insert({ text = " to ", foreground = "Comment" })
			line:insert({ text = "expand", foreground = "#AAAA77" })
			line:insert({ text = ", ", foreground = "Comment" })
			line:insert({ text = "i", foreground = "#77AAAA" })
			line:insert({ text = " to ", foreground = "Comment" })
			line:insert({ text = "install recommended", foreground = "#77AAAA" })
			line:insert({ text = ", or ", foreground = "Comment" })
			line:insert({ text = "u", foreground = "#AA77AA" })
			line:insert({ text = " to ", foreground = "Comment" })
			line:insert({ text = "uninstall all", foreground = "#AA77AA" })
			line:insert({ text = ")", foreground = "Comment" })

			-- global tool listing
		end

		write_line(line)

		-- Draw sub-tool listings
		if ui.expanded_global_tools:contains(global_tool_key) then
			for index, entry in ipairs(registry.global_tools[global_tool_key].entries) do
				local write_buffer = Table({ { text = "    " } })
				if index == #registry.global_tools[global_tool_key].entries then
					write_buffer:insert({ text = "└ ", foreground = "Comment" })
				else
					write_buffer:insert({ text = "│ ", foreground = "Comment" })
				end

				local tool_icon, tool_color = config.icons().not_installed, config.colors().not_installed
				if entry.is_installed then
					tool_icon, tool_color = config.icons().installed, config.colors().installed
				end

				write_buffer:insert({ text = tool_icon, foreground = tool_color })
				write_buffer:insert({ text = " " .. entry.name })
				write_buffer:insert({ text = (" (%s)"):format(entry.internal_name), foreground = "Comment" })

				-- global tool listing prompt
				if
					ui.lines[ui.cursor_row].type == "global_tool_listing"
					and ui.lines[ui.cursor_row].entry.internal_name == entry.internal_name
				then
					if entry.is_installed then
						write_buffer:insert({ text = "   (Press ", foreground = "Comment" })
						write_buffer:insert({ text = "u", foreground = "#AA77AA" })
						write_buffer:insert({ text = " to ", foreground = "Comment" })
						write_buffer:insert({ text = "uninstall", foreground = "#AA77AA" })
						write_buffer:insert({ text = " or ", foreground = "Comment" })
						write_buffer:insert({ text = "c", foreground = "#77AAAA" })
						write_buffer:insert({ text = " to ", foreground = "Comment" })
						write_buffer:insert({ text = "configure", foreground = "#AA7777" })
						write_buffer:insert({ text = ")", foreground = "Comment" })
					else
						write_buffer:insert({ text = "   (Press ", foreground = "Comment" })
						write_buffer:insert({ text = "i", foreground = "#77AAAA" })
						write_buffer:insert({ text = " to ", foreground = "Comment" })
						write_buffer:insert({ text = "install", foreground = "#77AAAA" })
						write_buffer:insert({ text = ")", foreground = "Comment" })
					end
				end
				write_line(write_buffer)
			end
		end
	end
end

-- The row that the cursor is on, used to keep the cursor in the same spot when reloading the window.
---@type integer
ui.cursor_row = 1

--- Updates the forge buffer. This should be called whenever state changes to the UI are made.
--- This will clear the entire buffer and redraw it using the current state of the UI.
---
--- @return nil
function ui.update_view()
	is_first_draw_call = true
	vim.api.nvim_set_option_value("modifiable", true, { buf = ui.buffer })
	write_line({
		{ text = config.icons().instruction_left, foreground = config.colors().window_title },
		{ text = " Forge ", background = config.colors().window_title, foreground = "#000000" },
		{ text = config.icons().instruction_right, foreground = config.colors().window_title },
	}, true)
	write_line({ { text = "" } })
	write_line({

		-- Expand
		{ text = config.icons().instruction_left, foreground = config.colors().instructions },
		{ text = " Expand (e) ", background = config.colors().instructions, foreground = "#000000" },
		{ text = config.icons().instruction_right, foreground = config.colors().instructions },

		{ text = "   " },

		-- Install
		{ text = config.icons().instruction_left, foreground = config.colors().instructions },
		{ text = " Install (i) ", background = config.colors().instructions, foreground = "#000000" },
		{ text = config.icons().instruction_right, foreground = config.colors().instructions },

		{ text = "   " },

		-- Uninstall
		{ text = config.icons().instruction_left, foreground = config.colors().instructions },
		{ text = " Uninstall (u) ", background = config.colors().instructions, foreground = "#000000" },
		{ text = config.icons().instruction_right, foreground = config.colors().instructions },

		{ text = "   " },

		-- Configure
		{ text = config.icons().instruction_left, foreground = config.colors().instructions },
		{ text = " Configure (c) ", background = config.colors().instructions, foreground = "#000000" },
		{ text = config.icons().instruction_right, foreground = config.colors().instructions },

		{ text = "   " },

		-- Refresh
		{ text = config.icons().instruction_left, foreground = config.colors().instructions },
		{ text = " Refresh (r) ", background = config.colors().instructions, foreground = "#000000" },
		{ text = config.icons().instruction_right, foreground = config.colors().instructions },

		{ text = "   " },

		-- Quit
		{ text = config.icons().instruction_left, foreground = config.colors().instructions },
		{ text = " Quit (q) ", background = config.colors().instructions, foreground = "#000000" },
		{ text = config.icons().instruction_right, foreground = config.colors().instructions },
	}, true)
	write_line({ { text = "" } })

	-- Global tools
	write_line({
		{ text = "  Global Tools" },
		{ text = (" (%s types available)"):format(#registry.global_tool_keys), foreground = "Comment" },
	})
	draw_global_tools()
	write_line({ { text = "" } })

	draw_languages()
	write_line({ { text = "" } })

	vim.fn.cursor({ ui.cursor_row, 0 })
	vim.api.nvim_set_option_value("modifiable", false, { buf = ui.buffer })
end

-- Returns the langauge at the given line number, or `nil` if there is no language at the line
--
---@param line_number integer The line number in the forge buffer to get the language at
--
---@return string | nil language_name The name of the language found
local function get_language_at_line(line_number)
	if ui.lines[line_number].type == "language" then
		return ui.lines[line_number].language
	else
		return nil
	end
end

-- Returns the language that the cursor is under, or `nil` if the cursor is not under a language
--
---@return string | nil language_name The name of the language found
function ui.get_language_under_cursor()
	return get_language_at_line(ui.cursor_row)
end

--- Opens the forge window. This is what happens when the ":Forge" command is executed.
---
--- @return nil
function ui.open_window()
	ui.reset_lines()

	-- Create the forge buffer
	ui.buffer = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = ui.buffer })

	-- Hide the cursor in the buffer
	if
		config.options.ui.hide_cursor
		or (config.options.ui.hide_cursor == nil and config.options.ui.window_options.cursorline)
	then
		vim.api.nvim_create_autocmd("BufEnter", {
			buffer = ui.buffer,
			callback = function()
				vim.cmd("hi Cursor blend=100")
				vim.cmd("set guicursor+=a:Cursor/lCursor")
			end,
		})
		vim.api.nvim_create_autocmd("BufLeave", {
			buffer = ui.buffer,
			callback = function()
				vim.cmd("hi Cursor blend=0")
				vim.cmd("set guicursor-=a:Cursor/lCursor")
			end,
		})
	end

	-- Calculate forge window dimensions
	local vim_width = vim.api.nvim_get_option_value("columns", { scope = "global" })
	local vim_height = vim.api.nvim_get_option_value("lines", { scope = "global" })
	ui.height = math.ceil(vim_height * 0.8 - 4)
	ui.width = 130

	-- Set mappings
	for key, action in pairs(config.options.ui.mappings) do
		vim.api.nvim_buf_set_keymap(ui.buffer, "n", key, (":lua require('forge.ui.actions').%s()<CR>"):format(action), {
			nowait = true,
			noremap = true,
			silent = true,
		})
	end

	-- Create the Forge window
	ui.window = vim.api.nvim_open_win(
		ui.buffer,
		true,
		vim.tbl_deep_extend("force", {
			row = math.ceil((vim_height - ui.height) / 2 - 1),
			col = math.ceil((vim_width - ui.width) / 2),
			width = ui.width,
			height = ui.height,
		}, config.options.ui.window_config)
	)

	-- Window options
	for option_name, option_value in pairs(config.options.ui.window_options) do
		vim.api.nvim_set_option_value(option_name, option_value, { win = ui.window })
	end
end

return ui
