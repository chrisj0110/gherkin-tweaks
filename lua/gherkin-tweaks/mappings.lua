local M = {}

function M.setup()
    vim.keymap.set("n", "<leader>mi", require("gherkin_tweaks").isolate_test, { desc = "Isolate test" })
end

return M

