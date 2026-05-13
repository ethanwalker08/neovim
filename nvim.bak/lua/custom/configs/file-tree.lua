local config = {}
function config.setup()
	require("nvim-tree").setup({
		filters = {
			git_ignored = false,
		},
		git = {
			enable = true,
			ignore = false,
		},
		renderer = {
			icons = {
				glyphs = {
					git = {
						untracked = "",
						unstaged = "~",
						staged = "✓",
						unmerged = "",
						renamed = "R",
						deleted = "",
						ignored = "◌",
					},
				},
				show = {
					git = true,
					modified = true,
				},
			},
		},

		-- Buffer-local mappings and small niceties for nvim-tree
		on_attach = function(bufnr)
			local api = require("nvim-tree.api")

			-- apply default mappings provided by nvim-tree
			if api and api.map and api.map.on_attach and api.map.on_attach.default then
				api.map.on_attach.default(bufnr)
			end
		end,

		-- note: custom mappings are provided via `on_attach` above; do not use
		-- the deprecated `view.mappings` option which newer nvim-tree rejects.
	})

	local prev = { new_name = "", old_name = "" } -- Prevents duplicate events
	vim.api.nvim_create_autocmd("User", {
		pattern = "NvimTreeSetup",
		callback = function()
			local events = require("nvim-tree.api").events
			events.subscribe(events.Event.NodeRenamed, function(data)
				if prev.new_name ~= data.new_name or prev.old_name ~= data.old_name then
					data = data
					Snacks.rename.on_rename_file(data.old_name, data.new_name)
				end
			end)
		end,
	})
end

return config
