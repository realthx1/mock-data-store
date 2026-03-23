--!optimize 2

local pages = require("./Pages")
local data_store_object_version_info = require("./DataStoreObjectVersionInfo")

--- https://create.roblox.com/docs/reference/engine/classes/DataStoreVersionPages
local mod = {}
local class_scope = setmetatable({}, { __index = pages.class_scope })

export type RawMockDataStoreVersionPages = pages.RawMockPages<
	data_store_object_version_info.MockDataStoreObjectVersionInfo
>
export type MockDataStoreVersionPages = setmetatable<RawMockDataStoreVersionPages, { __index: typeof(class_scope) }>

local function new(
	data_pages: { { data_store_object_version_info.MockDataStoreObjectVersionInfo } }
): MockDataStoreVersionPages
	return setmetatable(pages.new_raw(data_pages), { __index = class_scope })
end

class_scope.ClassName = "DataStoreVersionPages"

mod.class_scope = class_scope
mod.new = new

return mod
