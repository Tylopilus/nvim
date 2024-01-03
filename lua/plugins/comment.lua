return {
	"numToStr/Comment.nvim",
	cond = not vim.g.vscode, 
	dependencies = {
		"JoosepAlviste/nvim-ts-context-commentstring",
	},
	config = function()
        -- smart comments based on context
		function _G.__toggle_contextual(vmode)
			local cfg = require("Comment.config"):get()
			local U = require("Comment.utils")
			local Op = require("Comment.opfunc")
			local range = U.get_region(vmode)
			local same_line = range.srow == range.erow

			local ctx = {
				cmode = U.cmode.toggle,
				range = range,
				cmotion = U.cmotion[vmode] or U.cmotion.line,
				ctype = same_line and U.ctype.linewise or U.ctype.blockwise,
			}

			local lcs, rcs = U.parse_cstr(cfg, ctx)
			local lines = U.get_lines(range)

			local params = {
				range = range,
				lines = lines,
				cfg = cfg,
				cmode = ctx.cmode,
				lcs = lcs,
				rcs = rcs,
			}

			if same_line then
				Op.linewise(params)
			else
				Op.blockwise(params)
			end
		end

		require("Comment").setup({
			pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
		})

		vim.keymap.set("n", "<Leader>c", "<cmd>set operatorfunc=v:lua.__toggle_contextual<CR>g@")
		vim.keymap.set("x", "<Leader>c", "<cmd>set operatorfunc=v:lua.__toggle_contextual<CR>g@")
	end,
	lazy = false,
}
