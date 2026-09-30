vim.pack.add({
	"https://github.com/lewis6991/gitsigns.nvim",
})

local gs = require("gitsigns")

gs.setup({
	current_line_blame = true,
	on_attach = function(bufnr)
		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		-- Navigation
		map({ "n", "v" }, "]c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]c", bang = true })
			else
				gs.nav_hunk("next")
			end
		end, { desc = "Jump to next hunk" })

		map({ "n", "v" }, "[c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "[c", bang = true })
			else
				gs.nav_hunk("prev")
			end
		end, { desc = "Jump to previous hunk" })

		-- Actions
		-- visual mode
		map("v", "<leader>hs", function()
			gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "stage git hunk" })
		map("v", "<leader>hr", function()
			gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "reset git hunk" })
		-- normal mode (stage_hunk on a staged hunk unstages it)
		map("n", "<leader>hs", gs.stage_hunk, { desc = "git stage/unstage hunk" })
		map("n", "<leader>hr", gs.reset_hunk, { desc = "git reset hunk" })
		map("n", "<leader>hS", gs.stage_buffer, { desc = "git Stage buffer" })
		map("n", "<leader>hR", gs.reset_buffer, { desc = "git Reset buffer" })
		map("n", "<leader>hp", gs.preview_hunk, { desc = "preview git hunk" })
		map("n", "<leader>hb", function()
			gs.blame_line({ full = false })
		end, { desc = "git blame line" })
		map("n", "<leader>hd", gs.diffthis, { desc = "git diff against index" })
		map("n", "<leader>hD", function()
			gs.diffthis("~")
		end, { desc = "git diff against last commit" })

		-- Toggles
		map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "toggle git blame line" })
		map("n", "<leader>td", gs.preview_hunk_inline, { desc = "show deleted lines of hunk inline" })

		-- Text object
		map({ "o", "x" }, "ih", gs.select_hunk, { desc = "select git hunk" })
	end,
})
