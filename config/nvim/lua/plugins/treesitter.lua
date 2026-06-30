return {
  {
    "nvim-treesitter/nvim-treesitter",

    branch = "master", -- This branch is specifically for 0.11 nvim and older
		-- May have to change if newer nvim version is used

    lazy = false,

    build = ":TSUpdate",

    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
					"c",
					"cpp",
          "lua",
          "vim",
          "vimdoc",
          "query",
          "javascript",
          "typescript",
          "tsx",
          "html",
          "css",
          "json",
          "bash",
          "markdown",
          "markdown_inline",
        },

        sync_install = false,
        auto_install = true,

        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },

        indent = {
          enable = true,
        },
      })
    end,
  },
}
