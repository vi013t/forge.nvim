local public = {}

function public.setup_lsps()
	require("nvim-treesitter.install").compilers = { "clang" }
	require('nvim-treesitter.configs').setup({
		ensure_installed = {},
		sync_install = false,
		highlight = {
			enable = true,
		},
		playground = {
			enable = true
		},
	})

	local opts = {
		diagnostics = {
			underline = true,
			update_in_insert = false,
			virtual_text = {
				spacing = 4,
				source = 'if_many',
				prefix = "●"
			},
			severity_sort = true
		},
		inlay_hints = {
			enabled = false
		},
		capabilities = {},
		format = {
			formatting_options = nil,
			timeout_ms = nil
		},
		servers = {
			lua_ls = {
				settings = {
					Lua = {
						workspace = {
							checkThirdParty = false
						},
						completion = {
							callSnippet = "Replace",
						}
					}
				}
			}
		},
		setup = {},
	}

	require("neodev").setup({})

	local icons = {
		Error = " ",
		Warn  = " ",
		Hint  = " ",
		Info  = " ",
	}

	local register_capability = vim.lsp.handlers["client/registerCapability"]

	---@diagnostic disable-next-line: duplicate-set-field
	vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx)
		return register_capability(err, res, ctx)
	end

	-- diagnostics
	for name, icon in pairs(icons) do
		name = "DiagnosticSign" .. name
		vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
	end

	local inlay_hint = vim.lsp.buf.inlay_hint or vim.lsp.inlay_hint

	if opts.inlay_hints.enabled and inlay_hint then
		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				local buffer = args.buf ---@type number
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if client.supports_method("textDocument/inlayHint") then
					inlay_hint(buffer, true)
				end
			end
		})
	end

	if type(opts.diagnostics.virtual_text) == "table" and opts.diagnostics.virtual_text.prefix == "icons" then
		opts.diagnostics.virtual_text.prefix = function(diagnostic)
			for d, icon in pairs(icons) do
				if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
					return icon
				end
			end
		end
	end

	vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

	local servers = opts.servers
	local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
	local capabilities = vim.tbl_deep_extend(
		"force",
		{},
		vim.lsp.protocol.make_client_capabilities(),
		has_cmp and cmp_nvim_lsp.default_capabilities() or {},
		opts.capabilities or {}
	)

	local function setup_server(server)
		local server_opts = vim.tbl_deep_extend("force", {
			capabilities = vim.deepcopy(capabilities),
		}, servers[server] or {})

		if opts.setup[server] then
			if opts.setup[server](server, server_opts) then
				return
			end
		elseif opts.setup["*"] then
			if opts.setup["*"](server, server_opts) then
				return
			end
		end
		require("lspconfig")[server].setup(server_opts)
	end

	-- get all the servers that are available through mason-lspconfig
	local have_mason, mlsp = pcall(require, "mason-lspconfig")
	local all_mslp_servers = {}
	if have_mason then
		all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
	end

	local ensure_installed = {} ---@type string[]
	for server, server_opts in pairs(servers) do
		if server_opts then
			server_opts = server_opts == true and {} or server_opts
			-- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
			if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
				setup_server(server)
			else
				ensure_installed[#ensure_installed + 1] = server
			end
		end
	end

	if have_mason then
		mlsp.setup({ ensure_installed = ensure_installed, handlers = { setup_server } })
	end
end

return public
