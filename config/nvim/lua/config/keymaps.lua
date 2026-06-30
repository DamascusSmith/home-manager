vim.g.mapleader = " "

--- Generic Vim Stuff ---
-- All mighty yank
vim.keymap.set('n', "<leader>y", "\"+y")
vim.keymap.set('v', "<leader>y", "\"+y")
vim.keymap.set('n', "<leader>Y", "\"+Y")

-- Diagnostic Window
vim.keymap.set('n', 
"<leader>d", 
"<cmd> lua vim.diagnostic.open_float() <CR>", 
{ desc = "Opens diagnostic floating window" })

-- Alternate file rebind
vim.keymap.set('n', "<leader><leader>", "<C-^>", { desc = "vim 'Alternate file' rebind" })


--- LSP Keymappings ---
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(event)
		local opts = {
			buffer = event.buf,
		}

		vim.keymap.set('n', "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set('n', "gr", vim.lsp.buf.references, opts)
		vim.keymap.set('n', "K", vim.lsp.buf.hover, opts)
		vim.keymap.set('n', "<leader>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set({'n', 'v'}, "<leader>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set('n', "<leader>d", vim.lsp.buf.definition, opts)

		vim.keymap.set('n', "[d", function()
			vim.diagnostic.jump({
				count = -1,
				float = true,
			})
		end, opts)

		vim.keymap.set('n', "]d", function()
			vim.diagnostic.jump({
				count = 1,
				float = true,
		})
		end, opts)
	end,
})
