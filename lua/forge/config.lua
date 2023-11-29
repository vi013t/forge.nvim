local public = Table({})

public.default_config = {
	developer_mode = false,
	symbols = {
		right_arrow = "▸",
		down_arrow = "▾",
	},
	lockfile = vim.fn.stdpath("data") .. "/forge.lock",
	lsp_options = {
		diagnostics = {
			underline = true,
			update_in_insert = false,
			virtual_text = {
				spacing = 4,
				source = "if_many",
				prefix = "●",
			},
			severity_sort = true,
		},
		inlay_hints = {
			enabled = false,
		},
		capabilities = {},
		format = {
			formatting_options = nil,
			timeout_ms = nil,
		},
		servers = {
			lua_ls = {
				settings = {
					Lua = {
						workspace = {
							checkThirdParty = false,
						},
						completion = {
							callSnippet = "Replace",
						},
					},
				},
			},
		},
		setup = {},
	},
}

public.options = public.default_config

function public.set_config(config)
	public.config = vim.tbl_deep_extend("force", vim.deepcopy(public.options), config)
end

return public
