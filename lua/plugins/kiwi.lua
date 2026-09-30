vim.pack.add({
	"https://github.com/serenevoid/kiwi.nvim",
})

local kiwi = require("kiwi")

kiwi.setup({
	{
		name = "work",
		path = "/home/helge/dev/notes/",
	},
})

vim.keymap.set("n", "<leader>ww", kiwi.open_wiki_index, { desc = "Open Wiki index" })
vim.keymap.set("n", "T", kiwi.todo.toggle, { desc = "Toggle Markdown Task" })
