local config = {}

function config.setup()
	local prettier_filetypes = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"svelte",
		"html",
		"css",
		"scss",
		"json",
		"jsonc",
		"yaml",
		"markdown",
	}

	local conform_util = require("conform.util")
	local prettier_root_files = {
		".prettierrc",
		".prettierrc.json",
		".prettierrc.yml",
		".prettierrc.yaml",
		".prettierrc.json5",
		".prettierrc.js",
		".prettierrc.cjs",
		".prettierrc.mjs",
		".prettierrc.toml",
		"prettier.config.js",
		"prettier.config.cjs",
		"prettier.config.mjs",
		"prettier.config.ts",
		"package.json",
	}
	local prettier_cwd = conform_util.root_file(prettier_root_files)
	local has_prettier_root = function(_, ctx)
		return prettier_cwd(nil, ctx) ~= nil
	end
	local formatters_by_ft = {
		lua = { "stylua" },
		python = { "ruff_format" },
	}

	for _, filetype in ipairs(prettier_filetypes) do
		formatters_by_ft[filetype] = { "prettierd", "prettier", stop_after_first = true }
	end

	require("conform").setup({
		notify_on_error = false,
		format_on_save = function()
			return {
				timeout_ms = 750,
				lsp_format = "fallback",
			}
		end,
		formatters = {
			prettierd = {
				cwd = prettier_cwd,
				require_cwd = true,
				condition = has_prettier_root,
			},
			prettier = {
				cwd = prettier_cwd,
				require_cwd = true,
				condition = has_prettier_root,
			},
		},
		formatters_by_ft = formatters_by_ft,
	})
end

return config
