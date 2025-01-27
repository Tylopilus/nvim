vim.g.mapleader = " "

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.scrolloff = 8
vim.opt.wrap = false
vim.opt.textwidth = 80
vim.diagnostic.config({virtual_text=false})

-- Navigate vim panes better
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "B", "_")
vim.keymap.set("n", "E", "$")
vim.keymap.set("v", "B", "_")
vim.keymap.set("v", "E", "$")

vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set("n", "Y", '"+y')
vim.keymap.set("v", "Y", '"+y')
vim.keymap.set("n", "yY", '"+y$')
-- Quickfix list
vim.keymap.set("n", "<leader>qq", vim.diagnostic.setqflist, { desc = "Open diagnostics in [q]uickfix list"});
vim.keymap.set("n", "<C-[>", "<cmd>:cprevious<CR>", {desc = "Go previous entry in quickfix list"})
vim.keymap.set("n", "<C-]>", "<cmd>:cnext<CR>", {desc = "Go next entry in quickfix list"})
vim.keymap.set('n', '<C-\\>', function()
    for _, win in pairs(vim.fn.getwininfo()) do
        if win.quickfix == 1 then
            vim.cmd('cclose')
            return
        end
    end
    vim.cmd('copen')
end)
