local M = {}

local augroup = vim.api.nvim_create_augroup
local keymap = vim.api.nvim_set_keymap

M.my_vscode = augroup("MyVSCode", {})

vim.filetype.add({
    pattern = {
        [".*%.ipynb.*"] = "python",
        -- uses lua pattern matching
        -- rathen than naive matching
    },
})

local function notify(cmd)
    return string.format("<cmd>call VSCodeNotify('%s')<CR>", cmd)
end

local function v_notify(cmd)
    return string.format("<cmd>call VSCodeNotifyVisual('%s', 1)<CR>", cmd)
end

keymap("n", "<Leader>xr", notify("references-view.findReferences"), { silent = true })  -- language references
keymap("n", "<Leader>xd", notify("workbench.actions.view.problems"), { silent = true }) -- language diagnostics
keymap("n", "gr", notify("editor.action.goToReferences"), { silent = true })
keymap("n", "<Leader>rn", notify("editor.action.rename"), { silent = true })
keymap("n", "<Leader>f", notify("editor.action.formatDocument"), { silent = true })
keymap("n", "<Leader>ca", notify("editor.action.refactor"), { silent = true })                   -- language code actions
keymap("n", "<Leader>ai", notify("workbench.panel.chat.view.copilot.focus"), { silent = true })                   -- language code actions

keymap("n", "<Leader>rg", notify("workbench.action.findInFiles"), { silent = true })             -- use ripgrep to search files
keymap("n", "<Leader>ts", notify("workbench.action.toggleSidebarVisibility"), { silent = true })
keymap("n", "<Leader>th", notify("workbench.action.toggleAuxiliaryBar"), { silent = true })      -- toggle docview (help page)
keymap("n", "<Leader>tp", notify("workbench.action.togglePanel"), { silent = true })
keymap("n", "<Leader>tw", notify("workbench.action.terminal.toggleTerminal"), { silent = true }) -- terminal window

keymap("v", "<Leader>f", v_notify("editor.action.formatSelection"), { silent = true })
keymap("v", "<Leader>ca", v_notify("editor.action.refactor"), { silent = true })
keymap("v", "<Leader>fc", v_notify("workbench.action.showCommands"), { silent = true })

-- vscode harpoon config
keymap('n', '<leader>ad', notify("vscode-harpoon.addEditor"), { silent = true })
keymap('n', '<C-e>', notify("vscode-harpoon.editEditors"), { silent = true })
keymap('n', '<C-j>', notify("vscode-harpoon.gotoEditor1"), { silent = true })
keymap('n', '<C-k>', notify("vscode-harpoon.gotoEditor2"), { silent = true })
keymap('n', '<C-l>', notify("vscode-harpoon.gotoEditor3"), { silent = true })

-- lazygit
keymap('n', '<leader>g', notify("lazygit.openLazygit"), { silent = true })

-- nnoremap zM :call VSCodeNotify('editor.foldAll')<CR>
-- nnoremap zR :call VSCodeNotify('editor.unfoldAll')<CR>
-- nnoremap zc :call VSCodeNotify('editor.fold')<CR>
-- nnoremap zC :call VSCodeNotify('editor.foldRecursively')<CR>
-- nnoremap zo :call VSCodeNotify('editor.unfold')<CR>
-- nnoremap zO :call VSCodeNotify('editor.unfoldRecursively')<CR>
-- nnoremap za :call VSCodeNotify('editor.toggleFold')<CR>
--
-- function! MoveCursor(direction) abort
--     if(reg_recording() == '' && reg_executing() == '')
--         return 'g'.a:direction
--     else
--         return a:direction
--     endif
-- endfunction
--
-- nmap <expr> j MoveCursor('j')
-- nmap <expr> k MoveCursor('k')
--
keymap("n", "za", notify("editor.toggleFold"), { silent = true })
keymap("n", "zc", notify("editor.fold"), { silent = true })
keymap("n", "zC", notify("editor.foldRecursively"), { silent = true })
keymap("n", "zo", notify("editor.unfold"), { silent = true })
keymap("n", "zO", notify("editor.unfoldRecursively"), { silent = true })

-- dont break folds
local function moveCursor(direction)
    if vim.fn.reg_recording() == "" and vim.fn.reg_executing() == "" then
        return ("g" .. direction)
    else
        return direction
    end
end

vim.keymap.set("n", "k", function()
    return moveCursor("k")
end, { expr = true, remap = true })
vim.keymap.set("n", "j", function()
    return moveCursor("j")
end, { expr = true, remap = true })
return M
