return {
	"nvimtools/none-ls.nvim",
	cond = not vim.g.vscode,
	config = function()
		local null_ls = require("null-ls")
		local h = require("null-ls.helpers")

		local prettier_java = h.make_builtin({
			name = "prettier",
			meta = {
				url = "https://prettier.io/",
				description = "Prettier is an opinionated code formatter.",
			},
			method = null_ls.methods.FORMATTING,
			filetypes = { "java" },
			generator_opts = {
				command = "prettierd",
				args = function(params)
					return {
						"--stdin-filepath",
						params.bufname,
					}
				end,
				to_stdin = true,
			},
			factory = h.formatter_factory,
		})

		null_ls.setup({
			debug = false,
			sources = {
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.formatting.prettier,
				prettier_java,
			},
		})
		vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "Format file with formatter" })
	end,
}
