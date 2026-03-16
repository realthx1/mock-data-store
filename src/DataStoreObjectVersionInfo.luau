--!optimize 2

local instance = require("./Instance")

--- https://create.roblox.com/docs/reference/engine/classes/DataStoreObjectVersionInfo
local mod = {}
local class_scope = {}

export type MockDataStoreObjectVersionInfo = setmetatable<{
	CreatedTime: number,
	Version: string,
	IsDeleted: boolean,
}, { __index: typeof(class_scope) }>

local function new(version: string, creation_t: number, deleted: boolean): MockDataStoreObjectVersionInfo
	return setmetatable({
		CreatedTime = creation_t,
		Version = version,
		IsDeleted = deleted,
	}, { __index = class_scope })
end

class_scope.ClassName = "DataStoreObjectVersionInfo"
class_scope.__index = instance.class_scope

mod.new = new

return mod
