--!optimize 2

local data_store_service = require("@self/DataStoreService")
local storage = require("@self/storage")

local mod = {}

local function new()
	local state = storage.internal_global_state_new({})
	return data_store_service.new(state), state
end

mod.new = new

return mod
