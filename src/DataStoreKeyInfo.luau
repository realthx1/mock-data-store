--!optimize 2

local instance = require("./Instance")

--- https://create.roblox.com/docs/reference/engine/classes/DataStoreKeyInfo
local mod = {}
local class_scope = {}

export type MockDataStoreKeyInfo = setmetatable<{
	CreatedTime: number,
	UpdatedTime: number,
	Version: string,
	_user_ids: { number },
	_metadata: { [string]: any },
}, { __index: typeof(class_scope) }>

local function get_user_ids(self: MockDataStoreKeyInfo): { number }
	return self._user_ids
end

local function get_metadata(self: MockDataStoreKeyInfo): { [string]: any }
	return self._metadata
end

local function new(
	version: number,
	update_t: number,
	creation_t: number,
	user_ids: { number },
	metadata: { [string]: any }
): MockDataStoreKeyInfo
	return setmetatable({
		CreatedTime = creation_t,
		UpdatedTime = update_t,
		Version = tostring(version),
		_user_ids = user_ids,
		_metadata = metadata,
	}, { __index = class_scope })
end

class_scope.GetUserIds = get_user_ids
class_scope.GetMetadata = get_metadata
class_scope.ClassName = "DataStoreKeyInfo"
class_scope.__index = instance.class_scope

mod.new = new

return mod
