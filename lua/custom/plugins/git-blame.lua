return {
	"f-person/git-blame.nvim",
	event = "VeryLazy",
	opts = {
		enabled = true,
		message_template = "	<date>: <summary>", -- template for inline blame
		date_format = "%r", -- template for the date, check Date format section for more options
		message_when_not_committed = "Unstaged changes",
		gitblame_delay = 2000,             -- show inline blame after cursor is still for 2 seconds
		gitblame_max_commit_summary_length = 75, -- character limit for commit summaries to show
	},
}
