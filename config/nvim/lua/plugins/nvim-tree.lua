return {
	{
		"nvim-tree/nvim-tree.lua",

		lazy = false,

		opts = {
			view = {
				width = 35,
			},

			renderer = {
				-- Should re-enable these for icons at a later date
				icons = {
					show = {
						file = false,
						folder = false,
						folder_arrow = false,
						git = false,
					},
				},
			},
		},

		keys = {
			{
				"<leader>e",
				"<cmd>NvimTreeToggle<cr>",
				desc = "Toggle file explorer",
			},
		},
	},
}
