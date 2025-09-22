-- iamcco's Markdown Preview config
vim.cmd([[
      function! OpenBrowserInBackground(url)
        execute "silent !open -g " . shellescape(a:url)
      endfunction
    ]])

-- tell markdown-preview to use it
vim.g.mkdp_browserfunc = "OpenBrowserInBackground"
vim.g.mkdp_auto_close = 1
vim.g.mkdp_markdown_css = vim.fn.expand("~/.config/nvim/css/markdown.css")
vim.g.mkdp_port = "3264"
vim.g.mkdp_combine_preview = 1
vim.g.mkdp_combine_preview_auto_refresh = 1
