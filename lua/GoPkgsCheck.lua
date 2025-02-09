local M = {
  file_name = "go.mod",
  namespace = vim.api.nvim_create_namespace("go-pkgs-check"),
}

M.setup = function()
  -- nothing
  vim.cmd("command! GoPkgsCheckShow" .. " lua require('GoPkgsCheck').show()")
  vim.cmd("command! GoPkgsCheckClear" .. " lua require('GoPkgsCheck').clear()")
  vim.cmd("command! GoPkgsCheckUpdate" .. " lua require('GoPkgsCheck').update()")
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

local isGoModFile = function()
  local buf_name = vim.api.nvim_buf_get_name(0)

  return M.file_name == string.match(buf_name, M.file_name .. "$")
end

M.show = function()
  if isGoModFile() ~= true then
    return
  end

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

      local bufnr = vim.fn.bufnr()
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
            vim.api.nvim_buf_set_extmark(bufnr, M.namespace, line_num, 0, {
              id = line_num,
              virt_text_pos = "eol",
              priority = 100,
              virt_text = { { "| new version available: " .. final, "WarningMsg" } },
            })
          else
            vim.api.nvim_buf_del_extmark(bufnr, M.namespace, line_num)
          end
        end,

        on_stdout = function(_, data)
          value = value .. table.concat(data)
        end,
      })
    end
  end
end

M.update = function()
  if isGoModFile() ~= true then
    return
  end

  local cur_line = vim.fn.getcurpos()[2]
  if cur_line < 1 then
    vim.print("Not valid module")
    return
  end

  local node = require("nvim-treesitter.ts_utils").get_node_at_cursor()
  for _, req_spec in pairs(node:named_children()) do
    local mod_path = req_spec:named_child(0)
    local ver = req_spec:named_child(1)

    if mod_path == nil or ver == nil then
      return
    end

    local mod_name = vim.treesitter.get_node_text(mod_path, 0)
    local line_num, _ = req_spec:range()

    if (line_num + 1) == cur_line then
      local bufnr = vim.fn.bufnr()
      local cmd_to_run = { "go", "get", "-u", "-v", mod_name }

      vim.fn.jobstart(cmd_to_run, {
        on_exit = function(_, exit_code)
          if exit_code ~= 0 then
            vim.print("Error running cmd: " .. cmd_to_run)
            return
          end

          vim.api.nvim_buf_del_extmark(bufnr, M.namespace, line_num)
        end,

        on_stdout = function(_, _)
          vim.print("Updated: " .. mod_name)
        end,
      })

      vim.print("updating " .. mod_name .. " ...")
    end
  end
end

M.clear = function()
  if isGoModFile() ~= true then
    return
  end

  vim.api.nvim_buf_clear_namespace(vim.fn.bufnr(), M.namespace, 0, -1)
end

return M
