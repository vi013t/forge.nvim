local highlighter = {}

function highlighter.setup_highlighters()
	require("nvim-treesitter.install").compilers = { "clang" }
	require("nvim-treesitter.configs").setup({
		ensure_installed = {},
		sync_install = false,
		highlight = {
			enable = true,
		},
		playground = {
			enable = true,
		},
	})
end

return highlighter
