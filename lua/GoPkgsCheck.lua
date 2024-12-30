local M = {}

M.setup = function()
  -- nothing
end

local process_payload = function(input)
  if string.len(input) == 0 then
    return ""
  end

  local splitted = vim.split(input, " ")

  if splitted[3] == nil then
    return ""
  end

  local ver = splitted[3]

  -- remove square brackets around version number
  return string.sub(ver, 2, string.len(ver) - 1)
end

M.check = function()
  local bufnr = vim.fn.bufnr()
  local namespace = vim.api.nvim_create_namespace("go-pkgs-check")
  local query_string = "(require_directive) @require_spec"

  local parser = require("nvim-treesitter.parsers").get_parser()

  local query = vim.treesitter.query.parse(parser:lang(), query_string)

  local tree = parser:parse()[1]

  for _, node in query:iter_captures(tree:root(), 0) do
    for _, req_spec in pairs(node:named_children()) do
      local mod_path = req_spec:named_child(0)
      local ver = req_spec:named_child(1)

      if mod_path == nil or ver == nil then
        return
      end

      local cmd_to_run = { "go", "list", "-m", "-u", "-mod=readonly", vim.treesitter.get_node_text(mod_path, 0) }
      local value = ""
      local ln, _ = req_spec:range()

      local line_num = ln

      vim.fn.jobstart(cmd_to_run, {
        on_exit = function(_, exit_code)
          if exit_code ~= 0 then
            vim.print("Error running cmd: " .. cmd_to_run)
            return
          end

          local final = process_payload(value)

          if final ~= "" then
            vim.api.nvim_buf_set_extmark(bufnr, namespace, line_num, 0, {
              id = line_num,
              virt_text_pos = "eol",
              priority = 100,
              virt_text = { { "| new version available: " .. final, "WarningMsg" } },
            })
          else
            vim.api.nvim_buf_del_extmark(bufnr, namespace, line_num)
          end
        end,

        on_stdout = function(_, data)
          value = value .. table.concat(data)
        end,
      })
    end
  end
end

return M
