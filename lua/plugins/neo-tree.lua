return {
	"nvim-neo-tree/neo-tree.nvim",
	cond = not vim.g.vscode,
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
		-- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
	},

	config = function()
      -- vim.keymap.set("n", "<leader>pv", "<cmd>:Neotree position=current<CR>")
        vim.keymap.set("n", "<leader>pv", "<cmd>:Neotree position=current reveal_force_cwd<cr>")
		require("neo-tree").setup({
			default_component_configs = {
				window = {
					position = "current",
				},
			},
			filesystem = {
				follow_current_file = {
					enabled = true,
				},
                hijack_netrw_behavior = "open_current",
                group_empty_dirs = true,
                scan_mode = "deep",
			},
            buffers = {
              follow_current_file = {
                enabled = true,
              },
            }
		})
	end,
}
