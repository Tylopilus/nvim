local function create_java_boilerplate(file_type)
  -- Get the current buffer's directory
  local file_path = vim.fn.expand('%:p:h')
  
  -- Extract package name from file path
  local package_name = file_path:match(".-/src/main/java/(.+)$")
  if package_name then
    package_name = package_name:gsub("/", ".")
  else
    package_name = "com.example" -- Default package if not found
  end
  
  -- Get the file name without extension
  local file_name = vim.fn.expand('%:t:r')
  
  -- Create boilerplate content
  local content = {
    "package " .. package_name .. ";",
    "",
    "public " .. file_type .. " " .. file_name .. " {",
    "    // TODO: Implement " .. file_name,
    "}"
  }
  
  -- Insert the content into the current buffer
  vim.api.nvim_buf_set_lines(0, 0, -1, false, content)
  
  -- Move cursor to the appropriate position for editing
  vim.api.nvim_win_set_cursor(0, {4, 4})  -- Move to the TODO line
  
  -- Trigger completion
  vim.schedule(function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-x><C-o>', true, true, true), 'n', true)
  end)
end

-- Create commands for class and interface
vim.api.nvim_create_user_command('JavaClass', function()
  create_java_boilerplate("class")
end, {})

vim.api.nvim_create_user_command('JavaInterface', function()
  create_java_boilerplate("interface")
end, {})

-- Autocommand to set up Java-specific completion
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function()
    local cmp = require('cmp')
    cmp.setup.buffer({
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'path' },
        { name = 'buffer', keyword_length = 5 },
      }),
    })
  end
})
