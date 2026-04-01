return {
	"nvim-svelte/nvim-svelte-check",
	config = function()
		require("svelte-check").setup({
			command = "npm run check",
		})
	end,
}
