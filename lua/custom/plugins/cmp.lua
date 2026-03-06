return {
	-- nvim-cmp for autocompletion
	"hrsh7th/nvim-cmp",
	event = "InsertEnter",
	dependencies = {
		"hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
		"hrsh7th/cmp-buffer", -- Buffer completions
		"hrsh7th/cmp-path",   -- Path completions
		"L3MON4D3/LuaSnip", -- Snippet engine
		"saadparwaiz1/cmp_luasnip", -- LuaSnip completion source
	},
	config = function()
		local cmp = require("cmp")
		local mapping = require("custom.keymaps").cmp_mappings(cmp)
		cmp.setup({
			completion = {
				-- Keep non-AI completion manual: open only with Ctrl+Space.
				autocomplete = false,
				keyword_length = 2,
			},
			preselect = cmp.PreselectMode.None,
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body)
				end,
			},
			mapping = mapping,
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "luasnip" },
				{ name = "buffer" },
				{ name = "path" },
			}),
		})
	end,
}
