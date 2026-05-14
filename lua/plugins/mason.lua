return {
  {
    "mason-org/mason.nvim",
    optional = true,
    opts = {
      ui = {
        backdrop = 100,
        border = "rounded",
        height = 0.85,
        width = 0.8,
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },
}
