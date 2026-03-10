return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"williamboman/mason.nvim",
		},
		config = function()
			local dap = require("dap")
			local ui = require("dapui")

			require("dapui").setup({
				controls = {
					element = "repl",
					enabled = true,
					icons = {
						disconnect = "",
						pause = "",
						play = "",
						run_last = "",
						step_back = "",
						step_into = "",
						step_out = "",
						step_over = "",
						terminate = "",
					},
				},
				element_mappings = {},
				expand_lines = true,
				floating = {
					border = "single",
					mappings = {
						close = { "q", "<Esc>" },
					},
				},
				force_buffers = true,
				icons = {
					collapsed = "",
					current_frame = "",
					expanded = "",
				},
				layouts = {
					{
						elements = {
							{
								id = "scopes",
								size = 0.25,
							},
							{
								id = "breakpoints",
								size = 0.25,
							},
							-- {
							-- 	id = "stacks",
							-- 	size = 0.25,
							-- },
							-- {
							-- 	id = "watches",
							-- 	size = 0.25,
							-- },
						},
						position = "left",
						size = 40,
					},
					{
						elements = {
							{
								id = "repl",
								size = 0.5,
							},
							-- {
							-- 	id = "console",
							-- 	size = 0.5,
							-- },
						},
						position = "bottom",
						size = 10,
					},
				},
				mappings = {
					edit = "e",
					expand = { "<CR>", "<2-LeftMouse>" },
					open = "o",
					remove = "d",
					repl = "r",
					toggle = "t",
				},
				render = {
					indent = 1,
					max_value_lines = 100,
				},
			})

			dap.configurations.java = {
				{
					type = "java",
					request = "attach",
					name = "eplan-relaunch publish",
					hostName = "localhost",
					mainClass = "eplan-relaunch.core",
					projectName = "eplan-relaunch.core",
					port = "8887",
				},
				{
					type = "java",
					request = "attach",
					name = "eplan-relaunch author",
					hostName = "localhost",
					mainClass = "eplan-relaunch.core",
					projectName = "eplan-relaunch.core",
					port = "8888",
				},
				{
					type = "java",
					request = "attach",
					name = "eplan-digital-platform publish",
					hostName = "localhost",
					mainClass = "eplan-digital-platform.core",
					projectName = "eplan-digital-platform.core",
					port = "8887",
				},
				{
					type = "java",
					request = "attach",
					name = "eplan-digital-platform author",
					hostName = "localhost",
					mainClass = "eplan-digital-platform.core",
					projectName = "eplan-digital-platform.core",
					port = "8888",
				},
				{
					type = "java",
					request = "attach",
					name = "eplan-components author",
					hostName = "localhost",
					mainClass = "eplan-components.core",
					projectName = "eplan-components.core",
					port = "8888",
				},
				{
					type = "java",
					request = "attach",
					name = "eplan-components publish",
					hostName = "localhost",
					mainClass = "eplan-components.core",
					projectName = "eplan-components.core",
					port = "8887",
				},
				{
					type = "java",
					request = "attach",
					name = "branchenanimation",
					hostName = "localhost",
					mainClass = "branchenanimation.core",
					projectName = "branchenanimation.core",
					port = "8887",
				},
				{
					type = "java",
					request = "attach",
					name = "epulse",
					hostName = "localhost",
					mainClass = "epulse.core",
					projectName = "epulse.core",
					port = "8887",
				},
				{
					type = "java",
					request = "attach",
					name = "eplan-rittal-cloud",
					hostName = "localhost",
					mainClass = "eplan-rittal-cloud.core",
					projectName = "eplan-rittal-cloud.core",
					port = "8887",
				},
				{
					type = "java",
					request = "attach",
					name = "aem guides wknd author",
					hostName = "localhost",
					mainClass = "aem-guides-wknd.core",
					projectName = "aem-guides-wknd.core",
					port = "8888",
				},
			}

			vim.keymap.set("n", "<space>db", dap.toggle_breakpoint)
			-- Eval var under cursor
			vim.keymap.set("n", "<space>d?", function()
				require("dapui").eval(nil, { enter = true })
			end)

			vim.keymap.set("n", "<F1>", dap.continue)
			vim.keymap.set("n", "<F2>", dap.step_over)
			vim.keymap.set("n", "<F3>", dap.step_into)
			vim.keymap.set("n", "<F4>", dap.step_out)
			vim.keymap.set("n", "<F5>", dap.step_back)
			vim.keymap.set("n", "<F13>", dap.restart)

			dap.listeners.before.attach.dapui_config = function()
				ui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				ui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				ui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				ui.close()
			end
		end,
	},
}
