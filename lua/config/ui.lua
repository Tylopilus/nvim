-- Built-in message/cmdline UI (experimental in 0.12): no "Press ENTER"
-- prompts, highlighted cmdline, long output in a pager window.
require("vim._core.ui2").enable({})

-- Show LSP progress as native progress messages (also drives
-- vim.ui.progress_status() in lualine and the terminal's progress bar)
vim.api.nvim_create_autocmd("LspProgress", {
	group = vim.api.nvim_create_augroup("lsp-progress", { clear = true }),
	callback = function(ev)
		local value = ev.data.params.value
		vim.api.nvim_echo({ { value.message or "done" } }, false, {
			id = "lsp." .. ev.data.params.token,
			kind = "progress",
			source = "vim.lsp",
			title = value.title,
			status = value.kind ~= "end" and "running" or "success",
			percent = value.percentage,
		})
	end,
})
