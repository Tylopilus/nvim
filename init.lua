require("config.options")
require("config.keymaps")

-- Inside VS Code (vscode-neovim) only editing behaviour is wanted; VS Code
-- provides the UI, LSP, git and file navigation.
if vim.g.vscode then
	require("plugins.surround")
	require("config.vscode")
	return
end

require("config.ui")
require("config.commands")
require("plugins")
