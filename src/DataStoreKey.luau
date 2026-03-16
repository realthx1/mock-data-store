--!optimize 2
-- https://create.roblox.com/docs/reference/engine/classes/DataStoreKey

local instance = require("./Instance")

local mod = {}
local class_scope = {}

export type MockDataStoreKey = setmetatable<{
	KeyName: string,
}, { __index: typeof(class_scope) }>

local function new(name: string): MockDataStoreKey
	return setmetatable({
		KeyName = name,
	}, { __index = class_scope })
end

class_scope.ClassName = "DataStoreKey"
class_scope.__index = instance.class_scope

mod.new = new

return mod
