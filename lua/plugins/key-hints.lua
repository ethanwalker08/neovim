return {
  { "nvim-mini/mini.clue", enabled = false },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        {
          mode = { "n", "x", "v" },
          { "<leader><tab>", hidden = true },
          { "<leader>b", hidden = true },
          { "<leader>c", group = "+[C]ode/[C]opilot" },
          { "<leader>d", group = "+[D]ebug" },
          { "<leader>e", desc = "[E]xplorer" },
          { "<leader>f", desc = "[F]ormat" },
          { "<leader>g", group = "+[G]oto" },
          { "<leader>l", group = "+[L]azygit" },
          { "<leader>q", group = "+[Q]uit/[S]ession" },
          { "<leader>s", group = "+[S]earch" },
          { "<leader>t", group = "+[T]erminal" },
          { "<leader>u", group = "+[U]I" },
          { "<leader>w", desc = "[W]rite Buffer" },
          { "<leader>x", group = "+Diagnosti[x]/Quickfi[x]/[X]tras" },
          { "<leader>cs", group = "+[S]urround" },
        },
      },
    },
  },
}
