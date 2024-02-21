local config = require("forge.config")

local public = {}

function public.setup_lsps()
	-- Neodev (must be set up before lspconfig)
	local has_neodev, neodev = pcall(require, "neodev")
	if has_neodev then
		neodev.setup({})
	end

	-- Mason
	require("mason").setup({})

	-- Capabilities
	local register_capability = vim.lsp.handlers["client/registerCapability"]
	---@diagnostic disable-next-line: duplicate-set-field
	vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx)
		return register_capability(err, res, ctx)
	end

	-- Icons
	for name, icon in pairs(config.options.lsp.icons) do
		name = "DiagnosticSign" .. name
		vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
	end

	-- Inlay Hints
	-- local inlay_hint = vim.lsp.buf.inlay_hint or vim.lsp.inlay_hint
	-- if config.options.lsp.inlay_hints.enabled and inlay_hint then
	-- 	vim.api.nvim_create_autocmd("LspAttach", {
	-- 		callback = function(args)
	-- 			local client = vim.lsp.get_client_by_id(args.data.client_id)
	-- 			if client and client.supports_method("textDocument/inlayHint") then
	-- 				if inlay_hint then
	-- 					pcall(inlay_hint.enable) -- TODO: This is erroring on nightly atm, though seemed to work fine on stable 0.9. Needs investigating.
	-- 				end
	-- 			end
	-- 		end,
	-- 	})
	-- end

	-- Prefix virtual text with icons
	if
		type(config.options.lsp.diagnostics.virtual_text) == "table"
		and config.options.lsp.diagnostics.virtual_text.prefix == "icons"
	then
		config.options.lsp.diagnostics.virtual_text.prefix = function(diagnostic)
			for d, icon in pairs(config.options.lsp.icons) do
				if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
					return icon
				end
			end
		end
	end

	-- Diagnostics
	vim.diagnostic.config(vim.deepcopy(config.options.lsp.diagnostics))

	-- Server setup
	local servers = config.options.lsp.servers
	local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
	local capabilities = vim.tbl_deep_extend(
		"force",
		{},
		vim.lsp.protocol.make_client_capabilities(),
		has_cmp and cmp_nvim_lsp.default_capabilities() or {},
		config.options.lsp.capabilities or {}
	)
	local function setup_server(server)
		local server_opts = vim.tbl_deep_extend("force", {
			capabilities = vim.deepcopy(capabilities),
		}, servers[server] or {})

		if config.options.lsp.setup[server] then
			if config.options.lsp.setup[server](server, server_opts) then
				return
			end
		elseif config.options.lsp.setup["*"] then
			if config.options.lsp.setup["*"](server, server_opts) then
				return
			end
		end
		require("lspconfig")[server].setup(server_opts)
	end
	local mlsp = require("mason-lspconfig")
	local all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
	local ensure_installed = {} ---@type string[]
	for server, server_opts in pairs(servers) do
		if server_opts then
			server_opts = server_opts == true and {} or server_opts
			if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
				setup_server(server)
			else
				ensure_installed[#ensure_installed + 1] = server
			end
		end
	end
	mlsp.setup({ ensure_installed = ensure_installed, handlers = { setup_server } })

	-- Eagle.nvim
	local has_eagle, eagle = pcall(require, "eagle")
	if has_eagle then
		eagle.setup({})
	end

	-- lsp_signature.nvim
	local has_signature, signature = pcall(require, "lsp_signature")
	if has_signature then
		signature.setup({})
	end
end

return public
