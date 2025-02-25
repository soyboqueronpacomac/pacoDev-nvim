vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "dbout",
    "fugitive",
    "git",
    "help",
    "lspinfo",
    "man",
    "notify",
    "PlenaryTestPopup",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "neotest-output",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})
