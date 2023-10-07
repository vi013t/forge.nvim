local public = {}

public.progress_icons = {
	{ "", "" },
	{ "", "", "" },
	{ "", "", "", "" },
	{ "", "", "", "", "" },
	{ "", "", "", "", "", "" }
}

public.progress_colors = {
	{ "#FF0000", "#00FF00" },
	{ "#FF0000", "#FFFF00", "#00FF00" },
	{ "#FF0000", "#FFAA00", "#BBFF00", "#00FF00" },
	{ "#FF0000", "#FF8800", "#FFFF00", "#BBFF00", "#00FF00" },
	{ "#FF0000", "#FF6600", "#FFAA00", "#FFFF00", "#BBFF00", "#00FF00" }
}

-- Returns the progress icon and color for a given install fraction
--
---@param installed_count integer The number of utilities installed
---@param total_count integer The number of total utilities available
--
---@return string, string icon_color The icon and color strings
function public.get_icon_and_color(installed_count, total_count)
	return public.progress_icons[total_count][installed_count + 1], public.progress_colors[total_count][installed_count + 1]
end

return public

