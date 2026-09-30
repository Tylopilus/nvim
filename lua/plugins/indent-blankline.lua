vim.pack.add({
	"https://github.com/lukas-reineke/indent-blankline.nvim",
})

local highlight = {
	"NonText",
	"Whitespace",
}

require("ibl").setup({
	indent = { highlight = highlight, char = "▏" },
	whitespace = {
		highlight = highlight,
		remove_blankline_trail = false,
	},
	scope = { enabled = false },
})
