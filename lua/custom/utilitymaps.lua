vim.keymap.set("v", "<", "<gv", { desc = "Indent out and keeps the selection" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent in and keeps the selection" })

vim.keymap.set("n", "n", "nzzzv", { desc = "Goes to next result on the search and put the cursor in the middle" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Goes to prev result on the search and put the cursor in the middle" })
