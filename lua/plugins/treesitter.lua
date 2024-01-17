return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    cond = not vim.g.vscode,
    config = function()
        local configs = require("nvim-treesitter.configs")
        configs.setup({
            auto_installed = true,
            highlight = { enable = true },
            inded = { enable = true },
        })
    end,
}
