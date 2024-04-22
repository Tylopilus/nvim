return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "canary",
		dependencies = {
			{ "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
			{ "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
		},
		opts = {
			debug = true, -- Enable debugging
			-- See Configuration section for rest
		},
		-- See Commands section for default commands if you want to lazy load on them
		keys = {
			{
				"<leader>ai",
				"<cmd>lua require('CopilotChat').toggle()<CR>",
				desc = "CopilotChat - Help actions",
			},
			-- Show prompts actions with telescope
			{
				"<leader>ae",
				function()
					local actions = require("CopilotChat.actions")
					actions.pick(actions.prompt_actions({
						selection = require("CopilotChat.select").visual,
					}))
				end,
				-- Pick a prompt using vim.ui.select
				mode = "v",
				desc = "CopilotChat - Prompt actions (visual)",
			},
			{
				"<leader>ae",
				function()
					local actions = require("CopilotChat.actions")
					actions.pick(actions.prompt_actions({
						selection = require("CopilotChat.select").buffer,
					}))
				end,
				-- Pick a prompt using vim.ui.select
				mode = "n",
				desc = "CopilotChat - Prompt actions",
			},
		},
	},
}
