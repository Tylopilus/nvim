vim.g.mapleader = " "

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.scrolloff = 8
vim.opt.wrap = false
vim.opt.textwidth = 80

-- Hide the "[1/5]" search count message
vim.opt.shortmess:append("S")

vim.diagnostic.config({ virtual_text = false })

vim.filetype.add({ extension = { fe = "ferrum" } })

-- Folding: treesitter, falling back to indent when a filetype has no parser.
-- LSP folding is avoided on purpose: jdtls crashes in FoldingRangeHandler
-- (NegativeArraySizeException) when moving lines rapidly.
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
vim.o.foldcolumn = "1"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldtext = ""
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("fold-fallback", { clear = true }),
	callback = function(ev)
		if not pcall(vim.treesitter.get_parser, ev.buf) then
			vim.wo[0][0].foldmethod = "indent"
		end
	end,
})
