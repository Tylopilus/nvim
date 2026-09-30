vim.pack.add({
	"https://github.com/kdheepak/lazygit.nvim",
	"https://github.com/nvim-lua/plenary.nvim",
})

local open_file_path = vim.fn.stdpath("state") .. "/lazygit-open-file"
vim.env.LAZYGIT_NVIM_OPEN_FILE = open_file_path

vim.g.lazygit_on_exit_callback = function()
	local file = io.open(open_file_path, "r")
	if not file then
		return
	end

	local cwd = file:read("*l")
	local filename = file:read("*l")
	local line = tonumber(file:read("*l"))
	file:close()
	os.remove(open_file_path)

	if filename == nil or filename == "" then
		return
	end

	local target = filename
	if not vim.startswith(target, "/") then
		target = cwd .. "/" .. target
	end

	vim.schedule(function()
		local bufnr = vim.fn.bufadd(target)
		vim.fn.bufload(bufnr)
		vim.api.nvim_win_set_buf(0, bufnr)
		if line ~= nil and line > 0 then
			local last_line = vim.api.nvim_buf_line_count(bufnr)
			vim.api.nvim_win_set_cursor(0, { math.min(line, last_line), 0 })
		end
	end)
end

vim.keymap.set("n", "<leader>g", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
