return {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "<leader>fb", false },
      { "<leader>fB", false },
      { "<leader>fc", false },
      { "<leader>ff", false },
      { "<leader>fF", false },
      { "<leader>fg", false },
      { "<leader>fr", false },
      { "<leader>fR", false },
      { "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search Current Buffer" },
      { "<leader>s/", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },
      { "<leader>s.", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
      { "<leader>sf", LazyVim.pick("files"), desc = "Find Files" },
      { "<leader>sn", LazyVim.pick.config_files(), desc = "Find Config File", nowait = true },
    },
  },
  {
    "folke/noice.nvim",
    keys = {
      { "<leader>sn", false },
      { "<leader>snl", false },
      { "<leader>snh", false },
      { "<leader>sna", false },
      { "<leader>snd", false },
      { "<leader>snt", false },
    },
  },
}
