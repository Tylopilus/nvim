return {
    {
        "projekt0n/github-nvim-theme",
        cond = not vim.g.vscode,
        lazy = false,
        priority = 1000,
        config = function()
            require("github-theme").setup({
                palettes = {
                    -- Custom duskfox with black background
                },
            })
            vim.cmd.colorscheme("github_dark_dimmed")
        end,
    },
    -- {
    --     "olivercederborg/poimandres.nvim",
    --     cond = not vim.g.vscode,
    --     lazy = false,
    --     priority = 1000,
    --
    --     config = function()
    --         vim.cmd.colorscheme("poimandres")
    --     end,
    -- },
}
