return {
	{
		"mason-org/mason.nvim",
		opts = {}
	},

	{
		"mason-org/mason-lspconfig.nvim",
		-- ^^^ Connects mason package names to LSP config names

		dependencies = {
			"mason-org/mason.nvim",	 -- Downloads and manages executable programs like 		
															 -- clangd, lua-language-server, ect
			"neovim/nvim-lspconfig",
		-- ^^^ Provides nvim with established configurations letting the editor know
		-- which commands start which server
		-- which filetypes it supports
		-- how it detects the project root
		-- other server-specific defaults
			"hrsh7th/cmp-nvim-lsp",
		},

		opts = {
			ensure_installed = {
				"clangd",
				"lua_ls",
			},
		},

		config = function(_, opts)
			local capabilities = 
				require("cmp_nvim_lsp").default_capabilities()

			vim.lsp.config("*", {
				capabilities = capabilities,
			})

			require("mason-lspconfig").setup(opts)
		end,
	},

	{
		"neovim/nvim-lspconfig",
	},
}
