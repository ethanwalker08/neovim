return {
  {
    "zbirenbaum/copilot.lua",
    optional = true,
    opts = function(_, opts)
      local default_should_attach = opts.should_attach or require("copilot.config.should_attach").default

      opts.suggestion = vim.tbl_deep_extend("force", opts.suggestion or {}, {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = true,
        keymap = {
          accept = false,
          dismiss = "<Esc>",
        },
      })
      opts.panel = { enabled = false }
      opts.filetypes = vim.tbl_deep_extend("force", opts.filetypes or {}, {
        markdown = true,
        help = true,
      })
      opts.should_attach = function(bufnr, bufname)
        local name = vim.fs.basename(bufname or vim.api.nvim_buf_get_name(bufnr))
        if name == ".env" or name:match("^%.env%..+") then
          return false
        end

        return default_should_attach(bufnr, bufname)
      end

      return opts
    end,
    init = function()
      local group = vim.api.nvim_create_augroup("lazyvim_migration_copilot", { clear = true })

      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "BlinkCmpMenuOpen",
        callback = function()
          vim.b.copilot_suggestion_hidden = true
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "BlinkCmpMenuClose",
        callback = function()
          vim.b.copilot_suggestion_hidden = false
        end,
      })
    end,
  },
}
