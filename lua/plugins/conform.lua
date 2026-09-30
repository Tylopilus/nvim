vim.pack.add({
	"https://github.com/stevearc/conform.nvim",
})

require("conform").setup({
	formatters_by_ft = {
		ferrum = { "ferrumc" },
		lua = { "stylua" },
		javascript = { "prettier", stop_after_first = true },
		javascriptreact = { "prettierd", "prettier", stop_after_first = true },
		typescript = { "prettier", stop_after_first = true },
		typescriptreact = { "prettierd", "prettier", stop_after_first = true },
		html = { "prettier", stop_after_first = true },
		css = { "prettier", stop_after_first = true },
		scss = { "prettier", stop_after_first = true },
		java = { "prettier", stop_after_first = true },
		yaml = { "prettier", stop_after_first = true },
		json = { "prettier", stop_after_first = true },
		xml = { "prettier", stop_after_first = true },
		-- xml = { "xmlformatter", lsp_format = "last", stop_after_first = false },
	},
	default_format_opts = {
		lsp_format = "fallback",
	},
	-- format_on_save = { timeout_ms = 500 },
	formatters = {
		-- Always the globally installed prettier (npm i -g), never a copy found in some node_modules,
		-- so the editor formats exactly like the command line
		prettier = {
			command = "prettier",
			-- Line ranges for Java, set by format_changed.lua (needs the
			-- prettier-plugin-java fork with lineRanges: github.com/Tylopilus/prettier-java)
			append_args = function(_, ctx)
				local ranges = vim.b[ctx.buf].prettier_line_ranges
				return ranges and { "--line-ranges=" .. ranges } or {}
			end,
		},
		ferrumc = {
			command = "java",
			args = {
				"-jar",
				vim.fn.expand("~/dev/projects/ferrum/ferrum/compiler/target/ferrum-compiler-0.1.0-SNAPSHOT.jar"),
				"--format",
				"$FILENAME",
			},
			stdin = false,
		},
		shfmt = {
			prepend_args = { "-i", "2" },
		},
		xmlformatter = {
			prepend_args = { "--selfclose", "--blank" },
		},
	},
})

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

vim.keymap.set("n", "<leader>f", function()
	require("format_changed").format()
end, { desc = "Format lines changed since last commit" })
vim.keymap.set("x", "<leader>f", function()
	local first, last = vim.fn.line("v"), vim.fn.line(".")
	vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
	require("format_changed").format({ ranges = { { math.min(first, last), math.max(first, last) } } })
end, { desc = "Format selection" })
vim.keymap.set("n", "<leader>F", function()
	require("conform").format({ async = true })
end, { desc = "Format whole buffer" })
