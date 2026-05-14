local function ensure_formatter(formatters, formatter)
  if not vim.tbl_contains(formatters, formatter) then
    table.insert(formatters, formatter)
  end
end

return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.default_format_opts = vim.tbl_deep_extend("force", opts.default_format_opts or {}, {
        lsp_format = "fallback",
        timeout_ms = 750,
      })
      opts.notify_on_error = false
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.lua = { "stylua" }
      opts.formatters_by_ft.python = { "ruff_format" }

      local svelte_formatters = opts.formatters_by_ft.svelte or {}
      ensure_formatter(svelte_formatters, "prettier")
      opts.formatters_by_ft.svelte = svelte_formatters
    end,
  },
}
