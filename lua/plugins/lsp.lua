return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      local format_managed_servers = {
        cssls = true,
        html = true,
        jsonls = true,
        lua_ls = true,
        pyright = true,
        ruff = true,
        svelte = true,
        tailwindcss = true,
        ts_ls = true,
      }

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lazyvim_migration_lsp_keymaps", { clear = true }),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and format_managed_servers[client.name] then
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end

          pcall(vim.keymap.del, "n", "K", { buffer = ev.buf })
        end,
      })
    end,
    opts = {
      diagnostics = {
        float = {
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
          focusable = false,
          style = "minimal",
        },
      },
      servers = {
        ["*"] = {
          keys = {
            { "K", false },
            { "<leader>cc", false, mode = { "n", "x" } },
            { "<leader>gI", false },
            { "<leader>gT", false },
            {
              "<leader>gd",
              LazyVim.pick("lsp_definitions", { reuse_win = true }),
              desc = "Goto Definition",
              has = "definition",
            },
            {
              "<leader>gi",
              LazyVim.pick("lsp_implementations", { reuse_win = true }),
              desc = "Goto Implementation",
              has = "implementation",
            },
            {
              "<leader>gt",
              LazyVim.pick("lsp_type_definitions", { reuse_win = true }),
              desc = "Goto Type Definition",
              has = "typeDefinition",
            },
            {
              "<leader>cd",
              function()
                return vim.lsp.buf.hover({ border = "rounded" })
              end,
              desc = "Hover",
              has = "hover",
            },
          },
        },
      },
    },
  },
}
