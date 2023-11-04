local public = Table {}

public.default_config = {
	developer_mode = false,
	symbols = {
		right_arrow = "▸",
		down_arrow = "▾"
	},
	lockfile = vim.fn.stdpath("data") .. "/forge.lock",
}

public.options = public.default_config;

function public.set_config(config)
	public.config = vim.tbl_deep_extend("force", vim.deepcopy(public.options), config)
end

return public;
