local M = {}

M.setup = function()
  -- nothing
end

M.check = function()
  local query_string = "(require_directive) @require_spec"

  local parser = require("nvim-treesitter.parsers").get_parser()

  local query = vim.treesitter.query.parse(parser:lang(), query_string)

  local tree = parser:parse()[1]

  for _, node in query:iter_captures(tree:root(), 0) do
    vim.print("")

    for _, req_spec in pairs(node:named_children()) do
      local mod_path = req_spec:named_child(0)
      local ver = req_spec:named_child(1)

      if mod_path == nil or ver == nil then
        return
      end

      print(vim.treesitter.get_node_text(mod_path, 0), vim.treesitter.get_node_text(ver, 0))

      -- go list -m -u -mod=readonly github.com/aws/aws-sdk-go-v2
    end
  end
end

return M
