local vim = vim
local M = {}

function M.setup()
	require("notify").setup({
		background_colour = "#21252b",
		fps = 60,
		max_height = function()
			return math.floor(vim.o.lines * 0.75)
		end,
		max_width = function()
			return math.floor(vim.o.columns * 0.45)
		end,
		render = "wrapped-compact",
		stages = "fade_in_slide_out",
		timeout = 3000,
		top_down = false,
	})

	require("noice").setup({
		cmdline = {
			enabled = true,
			view = "cmdline_popup",
		},
		lsp = {
			progress = {
				enabled = true,
				view = "mini",
			},
			hover = {
				enabled = true,
			},
			signature = {
				enabled = true,
			},
		},
		messages = {
			enabled = true,
			view = "notify",
			view_error = "notify",
			view_warn = "notify",
			view_history = "messages",
			view_search = "virtualtext",
		},
		notify = {
			enabled = true,
			view = "notify",
		},
		popupmenu = {
			enabled = true,
			backend = "nui",
		},
		presets = {
			bottom_search = false,
			command_palette = true,
			long_message_to_split = true,
			inc_rename = false,
			lsp_doc_border = true,
		},
		routes = {
			{
				filter = {
					event = "msg_show",
					kind = "search_count",
				},
				view = "virtualtext",
			},
		},
		views = {
			cmdline_popup = {
				border = {
					style = "rounded",
				},
				position = {
					row = "40%",
					col = "50%",
				},
				size = {
					width = 60,
					height = "auto",
				},
				win_options = {
					winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
				},
			},
			cmdline_popupmenu = {
				border = {
					style = "rounded",
				},
				position = {
					row = "46%",
					col = "50%",
				},
				size = {
					width = 60,
					height = "auto",
				},
				win_options = {
					winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
				},
			},
			mini = {
				win_options = {
					winblend = 0,
				},
			},
			popup = {
				border = {
					style = "rounded",
				},
				win_options = {
					winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
				},
			},
		},
	})
end

return M
