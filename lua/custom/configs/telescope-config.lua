local config = {}

function config.setup()
	local vimgrep_arguments = {
		"rg",
		"--color=never",
		"--no-heading",
		"--with-filename",
		"--line-number",
		"--column",
		"--smart-case",
		"--hidden",
		"--no-ignore",
		"--glob=!**/.git/*",
	}

	require("telescope").setup({
		defaults = {
			vimgrep_arguments = vimgrep_arguments,
		},
		pickers = {
			find_files = {
				hidden = true,
				no_ignore = true,
				follow = true,
			},
			live_grep = {
				additional_args = function()
					return { "--hidden", "--no-ignore", "--glob=!**/.git/*" }
				end,
			},
			grep_string = {
				additional_args = function()
					return { "--hidden", "--no-ignore", "--glob=!**/.git/*" }
				end,
			},
		},
		extensions = {
			["ui-select"] = {
				require("telescope.themes").get_dropdown(),
			},
		},
	})

	-- Runtime guard: ensure nvim-treesitter.parsers.ft_to_lang exists
	-- This avoids modifying files under ~/.local/share and prevents
	-- Telescope from erroring when the parser API differs.
	pcall(function()
		local ok, parsers = pcall(require, "nvim-treesitter.parsers")
		if ok and type(parsers.ft_to_lang) ~= "function" then
			parsers.ft_to_lang = function(ft)
				return ft
			end
		end
	end)

	-- Enable Telescope extensions if they are installed
	pcall(require("telescope").load_extension, "fzf")
	pcall(require("telescope").load_extension, "ui-select")
end

return config
