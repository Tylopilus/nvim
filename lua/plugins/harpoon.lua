return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
    cond = not vim.g.vscode,
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup({})
		vim.keymap.set("n", "<leader>ad", function()
			harpoon:list():add()
		end, {desc = "Add current file to harpoon list"})
		vim.keymap.set("n", "<C-e>", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, {desc = "Toggle Harpoon quick menu"})

		vim.keymap.set("n", "<C-j>", function()
			harpoon:list():select(1)
		end, {desc = "Select first file in Harpoon list"})
		vim.keymap.set("n", "<C-k>", function()
			harpoon:list():select(2)
		end, {desc = "Select second file in Harpoon list"})
		vim.keymap.set("n", "<C-l>", function()
			harpoon:list():select(3)
		end, {desc = "Select third file in Harpoon list"})
		vim.keymap.set("n", "<C-;>", function()
			harpoon:list():select(4)
		end, {desc = "Select fourth file in Harpoon list"})
	end,
}
