local M = {}

vim = vim

-- add @cj and comment out all but current cucumber test
function M.isolate_test()
    -- add tag
    local starting_line = vim.fn.line('.')
    vim.cmd('normal! {')
    vim.cmd('normal! o@cj')
    local section_start_line = vim.fn.line(".")

    -- got the start line above, now get the end line
    vim.cmd('normal! }')
    local section_end_line = vim.fn.line(".")

    -- comment out all tests, but not the first line which has the column headers
    local first_example_line_found = false
    for i = section_start_line, section_end_line do
        -- loop through the lines, get the content of each, comment out all except the first one
        if not first_example_line_found and vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]:find("|", 1, true) then
            first_example_line_found = true
        else
            -- also don't comment out the test we want to run
            if i ~= starting_line + 1 then
                local line = vim.fn.getline(i)
                local updated_line = line:gsub("|", "# |", 1)
                vim.fn.setline(i, updated_line)
            end
        end
    end

    vim.api.nvim_win_set_cursor(0, {starting_line + 1, 0})
    vim.cmd(':w')
end

return M
