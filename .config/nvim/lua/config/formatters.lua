local M = {}

M.sql_formatter = {
  format = function(_, _, lines, callback)
    local dialects = { 'postgresql', 'clickhouse', 'sql' }
    local content = table.concat(lines, '\n')

    local function try_dialect(i)
      if i > #dialects then
        callback('sql-formatter: all dialects failed')
        return
      end

      vim.system(
        { vim.fn.exepath('sql-formatter'), '--language', dialects[i] },
        { stdin = content },
        vim.schedule_wrap(function(result)
          if result.code == 0 then
            local new_lines = vim.split(result.stdout, '\n', { plain = true })
            if new_lines[#new_lines] == '' then
              table.remove(new_lines)
            end
            callback(nil, new_lines)
          else
            try_dialect(i + 1)
          end
        end)
      )
    end

    try_dialect(1)
  end,
}

return M
