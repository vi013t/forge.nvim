local public = {}

function public.setup_autocomplete()
	local cmp = require("cmp")
	local lspkind = require("lspkind")

	cmp.setup({
		snippet = {
			expand = function(args)
				require("luasnip").lsp_expand(args.body)
			end,
		},
		window = {
			completion = cmp.config.window.bordered(),
			documentation = cmp.config.window.bordered(),
		},
		mapping = cmp.mapping.preset.insert({
			["<C-b>"] = cmp.mapping.scroll_docs(-4),
			["<C-f>"] = cmp.mapping.scroll_docs(4),
			["<C-Space>"] = cmp.mapping.complete(),
			["<C-e>"] = cmp.mapping.abort(),
			["<CR>"] = cmp.mapping.confirm({ select = true }),
		}),
		sources = cmp.config.sources({
			{ name = "nvim_lsp" },
			{ name = "luasnip" },
		}, {
			{ name = "buffer" },
		}),
		formatting = {
			format = lspkind.cmp_format({
				mode = "symbol_text",
				symbol_map = {
					Text = "",
					Method = "∷",
					Function = "λ",
					Constructor = "",
					Field = "",
					Variable = "𝝌",
					Class = "",
					Interface = "",
					Module = "",
					Property = "∷",
					Unit = "",
					Value = "",
					Enum = "",
					Keyword = "⋄",
					Snippet = "",
					Color = "",
					File = "",
					Reference = "&",
					Folder = "",
					EnumMember = "",
					Constant = "𝛫",
					Struct = "",
					Event = "",
					Operator = "𝚺",
					TypeParameter = "",
				},
			}),
		},
	})

	cmp.setup.cmdline({ "/", "?" }, {
		mapping = cmp.mapping.preset.cmdline(),
		sources = {
			{ name = "buffer" },
		},
	})

	cmp.setup.cmdline(":", {
		mapping = cmp.mapping.preset.cmdline(),
		sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
	})
end

return public
