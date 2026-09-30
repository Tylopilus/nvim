-- Each module declares its own plugins with vim.pack.add() and then configures
-- them. Plugin versions are pinned in nvim-pack-lock.json.
-- Update with :lua vim.pack.update(), review, then :write to apply.

-- UI
require("plugins.tokyonight") -- first, so later setups see its highlights
require("plugins.lualine")
require("plugins.statuscol")
require("plugins.indent-blankline")
require("plugins.which-key")
require("plugins.markview")
require("plugins.no-neck-pain")

-- Editing
require("plugins.guess-indent")
require("plugins.surround")
require("plugins.kiwi")
require("plugins.toggleterm")

-- Navigation
require("plugins.oil")
require("plugins.harpoon")
require("plugins.telescope")

-- Language support
require("plugins.tree-sitter-manager")
require("plugins.blink")
require("plugins.lsp")
require("plugins.conform")

-- Git
require("plugins.gitsigns")
require("plugins.lazygit")

-- Debugging
require("plugins.dap")

-- Tools
require("plugins.sync-aem")
