return {
	{
		"nvim-telescope/telescope.nvim",

		dependencies = {
			"nvim-lua/plenary.nvim",
		},

		config = function()
			local telescope = require("telescope")
			local builtin = require("telescope.builtin")

			telescope.setup({})

			vim.keymap.set('n', "<leader>pf", builtin.find_files, {
				desc = "Find Files (Telescope)",
			})

			vim.keymap.set('n', "<leader>ps", builtin.live_grep, {
				desc = "Search text(Telescope)",
			})
		end,
	},
}
