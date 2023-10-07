local public = {}

public.default_config = {
	developer_mode = false
}

public.config = public.default_config;

function public.set_config(config)
	public.config = vim.tbl_deep_extend("force", vim.deepcopy(public.config), config)
end

return public;
