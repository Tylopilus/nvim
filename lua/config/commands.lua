local function create_java_boilerplate(file_type)
	-- Get the current buffer's directory
	local file_path = vim.fn.expand("%:p:h")

	-- Extract package name from file path
	local package_name = file_path:match(".-/src/main/java/(.+)$")
	if package_name then
		package_name = package_name:gsub("/", ".")
	else
		package_name = "com.example" -- Default package if not found
	end

	-- Get the file name without extension
	local file_name = vim.fn.expand("%:t:r")

	-- Create boilerplate content
	local content = {
		"package " .. package_name .. ";",
		"",
		"public " .. file_type .. " " .. file_name .. " {",
		"    // TODO: Implement " .. file_name,
		"}",
	}

	-- Insert the content into the current buffer
	vim.api.nvim_buf_set_lines(0, 0, -1, false, content)

	-- Move cursor to the appropriate position for editing
	vim.api.nvim_win_set_cursor(0, { 4, 4 }) -- Move to the TODO line

	-- Trigger completion
	vim.schedule(function()
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-x><C-o>", true, true, true), "n", true)
	end)
end

-- Create commands for class and interface
vim.api.nvim_create_user_command("JavaClass", function()
	create_java_boilerplate("class")
end, {})

vim.api.nvim_create_user_command("JavaInterface", function()
	create_java_boilerplate("interface")
end, {})

vim.api.nvim_create_user_command("DebugAttachPublish", function()
	local dap = require("dap")
	dap.configurations.java = {
		{
			type = "java",
			request = "attach",
			name = "Attach to process",
			hostName = "localhost",
			port = 8887,
		},
	}
	dap.continue()
end, {})

vim.api.nvim_create_user_command("PRReview", function(opts)
	require("pr_review").start(opts.fargs[1], opts.fargs[2])
end, {
	nargs = "*",
	complete = function(arg_lead)
		return require("pr_review").complete(arg_lead)
	end,
})

vim.api.nvim_create_user_command("PRReviewPick", function()
	require("pr_review").pick()
end, {})

-- Update plugins, Mason packages and treesitter parsers. Neovim itself is
-- updated outside: brew upgrade neovim
vim.api.nvim_create_user_command("UpdateAll", function()
	vim.cmd("TSUpdate!")

	local registry = require("mason-registry")
	registry.update(vim.schedule_wrap(function(success, result)
		if not success then
			vim.notify("Mason: updating the registry failed: " .. tostring(result), vim.log.levels.ERROR)
			return
		end
		local outdated = vim.tbl_filter(function(pkg)
			return not pkg:is_installing() and pkg:get_installed_version() ~= pkg:get_latest_version()
		end, registry.get_installed_packages())
		if #outdated == 0 then
			vim.notify("Mason: all packages are up to date")
			return
		end
		for _, pkg in ipairs(outdated) do
			local from, to = pkg:get_installed_version(), pkg:get_latest_version()
			pkg:install(
				{ version = to },
				vim.schedule_wrap(function(ok)
					vim.notify(
						("Mason: %s %s %s -> %s"):format(ok and "updated" or "failed to update", pkg.name, from, to),
						ok and vim.log.levels.INFO or vim.log.levels.ERROR
					)
				end)
			)
		end
	end))

	-- Opens a tab listing the plugin changes: :write applies them, :quit discards them
	vim.pack.update()
	vim.notify("Plugins: review the changes, :write to apply them, then :restart")
end, { desc = "Update plugins, Mason packages and treesitter parsers" })
