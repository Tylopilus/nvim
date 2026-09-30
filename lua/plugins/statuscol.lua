vim.pack.add({
	"https://github.com/luukvbaal/statuscol.nvim",
})

local builtin = require("statuscol.builtin")
require("statuscol").setup({
	relculright = true,
	segments = {
		{
			sign = { namespace = { "diagnostic" }, maxwidth = 1, auto = true },
			click = "v:lua.ScSa",
		},
		{
			text = { " ", builtin.foldfunc, "  " },
			click = "v:lua.ScFa",
		},
		{ text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
		{
			sign = {
				text = { ".*" },
			},
			click = "v:lua.ScSa",
		},
	},
})
