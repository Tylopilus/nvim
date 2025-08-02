return {
	"MeanderingProgrammer/render-markdown.nvim",
	---@module 'render-markdown'
	---@type render.md.UserConfig
	opts = {
		file_types = { "markdown", "vimwiki" },
		anti_conceal = {
			enabled = false,
		},
		code = {
			language_icon = false,
		},
		completions = {
			blink = { enabled = false },
		},
	},
	-- ft = { "markdown", "Avante" },
	-- config = function()
	-- 	local rendermd = require("render-markdown")
	-- 	rendermd.setup({
	-- 		file_types = { "markdown", "Avante" },
	-- 		anti_conceal = {
	-- 			enabled = false,
	-- 			-- -- Which elements to always show, ignoring anti conceal behavior. Values can either be booleans
	-- 			-- -- to fix the behavior or string lists representing modes where anti conceal behavior will be
	-- 			-- -- ignored. Possible keys are:
	-- 			-- --  head_icon, head_background, head_border, code_language, code_background, code_border
	-- 			-- --  dash, bullet, check_icon, check_scope, quote, table_border, callout, link, sign
	-- 			-- ignore = {
	-- 			-- 	code_background = true,
	-- 			-- 	sign = true,
	-- 			-- },
	-- 			-- above = 0,
	-- 			-- below = 0,
	-- 		},
	-- 	})
	-- end,
}
