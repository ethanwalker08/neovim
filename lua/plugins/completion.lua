return {
  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      keymap = {
        preset = "none",
        ["<C-Space>"] = { "show", "hide" },
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "snippet_forward", "fallback" },
        ["<C-Tab>"] = { "select_prev", "fallback" },
        ["<C-J>"] = { "select_next", "fallback" },
        ["<Esc>"] = { "cancel", "fallback" },
      },
      appearance = {
        nerd_font_variant = "mono",
      },
      completion = {
        trigger = {
          prefetch_on_insert = true,
          show_in_snippet = true,
        },
        menu = {
          auto_show = false,
          min_width = 50,
          border = "rounded",
          draw = {
            treesitter = { "lsp" },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          treesitter_highlighting = true,
          window = {
            border = "rounded",
          },
        },
        ghost_text = {
          enabled = false,
        },
      },
      signature = {
        enabled = true,
        window = {
          border = "rounded",
        },
      },
      fuzzy = {
        implementation = "prefer_rust",
        prebuilt_binaries = { download = true },
      },
    },
  },
  {
    "saghen/blink.cmp",
    optional = true,
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      opts.sources.default = vim.tbl_filter(function(source)
        return source ~= "copilot"
      end, opts.sources.default or {})
      opts.sources.providers = opts.sources.providers or {}
      if opts.sources.providers.copilot then
        opts.sources.providers.copilot.enabled = false
      end

      opts.keymap = opts.keymap or {}
      opts.keymap["<Tab>"] = {
        function(cmp)
          local ok, suggestion = pcall(require, "copilot.suggestion")
          if ok and suggestion.is_visible() then
            suggestion.accept()
            return true
          end
          return cmp.snippet_forward()
        end,
        "select_next",
        "snippet_forward",
        "fallback",
      }
    end,
  },
}
