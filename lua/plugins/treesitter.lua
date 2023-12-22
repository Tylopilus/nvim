return {
  "nvim-treesitter/nvim-treesitter", build = ":TSUpdate",
  config = function()
    local configs = require('nvim-treesitter.configs')
    configs.setup({
      ensure_installed = {"lua", "javascript"},
      highlight = {enable = true},
      inded = {enable = true},
    })
  end
}
