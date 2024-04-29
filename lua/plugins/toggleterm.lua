return {
	{
		"akinsho/toggleterm.nvim",
		cond = not vim.g.vscode,
		version = "*",
		config = function()
			require("toggleterm").setup({
				direction = "float",
				on_open = function(term)
					vim.cmd("startinsert!")
					vim.api.nvim_buf_set_keymap(
						term.bufnr,
						"n",
						"q",
						"<cmd>close<CR>",
						{ noremap = true, silent = true }
					)
				end,
			})
		end,
	},
}
