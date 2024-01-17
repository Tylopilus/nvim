return {
    "nvimtools/none-ls.nvim",
    cond = not vim.g.vscode,
    config = function()
        local null_ls = require("null-ls")
        null_ls.setup({
            debug = true,
            sources = {
                null_ls.builtins.formatting.stylua,
                null_ls.builtins.formatting.prettier,
            },
        })
        vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, {})
    end,
}
