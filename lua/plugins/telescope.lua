return {
	"nvim-telescope/telescope.nvim",
	-- commit = "dc6fc321a5ba076697cca89c9d7ea43153276d81",
	-- tag = "0.1.8",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope-live-grep-args.nvim",
		"nvim-telescope/telescope-ui-select.nvim"
	},
	cond = not vim.g.vscode,
	config = function()
		local lga_actions = require("telescope-live-grep-args.actions")
		require("telescope").setup({
			defaults = {
				layout_config = {
					width = 0.7,
					horizontal = {
						preview_width = 0.6,
					},
				},
				mappings = {
					i = {
						["<C-_>"] = require("telescope.actions.layout").toggle_preview,
					},
				},
				preview = {
					hide_on_startup = true, -- hide previewer when picker starts
				},
				path_display = {
					trunctate = 2,
					filename_first = {
						reverse_directories = false,
					},
				},
			},
			pickers = {
				buffers = {
					ignore_current_buffer = true,
					sort_mru = true,
				},
			},
			extensions = {
				live_grep_args = {
					auto_quoting = true, -- enable/disable auto-quoting
					additional_args = {
						"--fixed-strings",
						"--hidden",
					},
					-- define mappings, e.g.
					mappings = { -- extend mappings
						i = {
							["<C-k>"] = lga_actions.quote_prompt(),
							["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
						},
					},
					-- ... also accepts theme settings, for example:
					-- theme = "dropdown", -- use dropdown theme
					-- theme = { }, -- use own theme spec
					-- layout_config = { mirror=true }, -- mirror preview pane
				},
			},
		})
		require("telescope").load_extension("ui-select")
		require("telescope").load_extension("live_grep_args")
		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<C-p>", function()
			require("telescope.builtin").find_files({
				hidden = true,
				find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
				file_ignore_patterns = {}, -- This will still respect .gitignore
			})
		end, { desc = "Find files by name" })
		vim.keymap.set(
			"n",
			"<leader>/",
			":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>",
			{ desc = "Search across all files" }
		)
		vim.keymap.set("n", "?", builtin.grep_string, {})
		vim.keymap.set("n", "<leader><space>", builtin.buffers, { desc = "[ ] Find existing buffers" })
	end,
}
