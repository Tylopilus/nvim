return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.5",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-live-grep-args.nvim",
  },
  cond = not vim.g.vscode,
  config = function()
    local lga_actions = require("telescope-live-grep-args.actions")
    require("telescope").setup({
      defaults = {
        layout_config = {
          width = 0.7,
          horizontal = {
            preview_width = 0.6,
          },
        },
        mappings = {
          i = {
            ["<C-p>"] = require("telescope.actions.layout").toggle_preview,
          },
        },
        preview = {
          hide_on_startup = true, -- hide previewer when picker starts
        },
      },
      pickers = {
        buffers = {
          ignore_current_buffer = true,
          sort_mru = true,
        },
      },
      extensions = {
        live_grep_args = {
          auto_quoting = true, -- enable/disable auto-quoting
          -- define mappings, e.g.
          mappings = {    -- extend mappings
            i = {
              ["<C-k>"] = lga_actions.quote_prompt(),
              ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
            },
          },
          -- ... also accepts theme settings, for example:
          -- theme = "dropdown", -- use dropdown theme
          -- theme = { }, -- use own theme spec
          -- layout_config = { mirror=true }, -- mirror preview pane
        },
      },
    })
    require("telescope").load_extension("live_grep_args")
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<C-p>", builtin.find_files, {})
    vim.keymap.set("n", "<leader>/", builtin.live_grep, {})
    vim.keymap.set("n", "?", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>", {})
    vim.keymap.set("n", "<leader><space>", builtin.buffers, { desc = "[ ] Find existing buffers" })
  end,
}
