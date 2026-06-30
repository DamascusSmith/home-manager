return {
  {
    "stevearc/oil.nvim",

    lazy = false,

    opts = {
      default_file_explorer = true,
      columns = {
        "size",
      },
    },

    keys = {
      {
        "<leader>pv",
        "<cmd>Oil<cr>",
        desc = "Open parent directory",
      },
    },
  },
}
