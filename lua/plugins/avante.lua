return {
	"yetone/avante.nvim",
	event = "VeryLazy",
	build = "make",
	opts = {
		-- add any opts here
		-- provider = "openai",
        provider = "claude",
		openai = {
			endpoint = "https://openrouter.ai/api/v1",
			model = "qwen/qwen-2.5-coder-32b-instruct",
		},
		mappings = {
			toggle = {
				debug = "<leader>ap",
			},
		},
	},
	dependencies = {
		"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
		"stevearc/dressing.nvim",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		--- The below is optional, make sure to setup it properly if you have lazy=true
	},
}
