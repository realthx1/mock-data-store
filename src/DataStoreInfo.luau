--!optimize 2

local instance = require("./Instance")

--- https://create.roblox.com/docs/reference/engine/classes/DataStoreKeyInfo
local mod = {}
local class_scope = {}

export type MockDataStoreInfo = setmetatable<{
	CreatedTime: number,
	UpdatedTime: number,
	DataStoreName: string,
}, { __index: typeof(class_scope) }>

local function new(name: string, update_t: number, creation_t: number): MockDataStoreInfo
	return setmetatable({
		CreatedTime = creation_t,
		UpdatedTime = update_t,
		DataStoreName = name,
	}, { __index = class_scope })
end

class_scope.ClassName = "DataStoreInfo"
class_scope.__index = instance.class_scope

mod.new = new

return mod
