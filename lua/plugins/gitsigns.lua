return {
	"lewis6991/gitsigns.nvim",
	cond = not vim.g.vscode, 
	config = function()
		require("gitsigns").setup({
			current_line_blame = true,
		})
	end,
}
