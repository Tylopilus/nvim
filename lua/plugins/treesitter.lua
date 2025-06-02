return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	cond = not vim.g.vscode,
	config = function()
		local configs = require("nvim-treesitter.configs")
		configs.setup({
			ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html" },
			auto_install = true,
			sync_install = false,
			highlight = { enable = true },
			indent = { enable = false },
			additional_parsers = {
				scss = {
					install_info = {
						url = "https://github.com/savetheclocktower/tree-sitter-scss", -- e.g., "https://github.com/your-username/tree-sitter-scss"
						files = { "src/parser.c", "src/scanner.c" }, -- Adjust based on repo
						branch = "master", -- Optional: specify branch
						generate_requires_npm = true, -- If `tree-sitter` CLI is needed
						requires_generate_from_grammar = true, -- If grammar needs to be generated
					},
				},
			},
		})
	end,
}
