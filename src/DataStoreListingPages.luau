--!optimize 2

local pages = require("./Pages")
local data_store_info = require("./DataStoreInfo")

--- https://create.roblox.com/docs/reference/engine/classes/DataStoreListingPages
local mod = {}
local class_scope = setmetatable({}, { __index = pages })

export type RawMockDataStoreListingPages =
	pages.RawMockPages<number, data_store_info.MockDataStoreInfo>
	& { Cursor: string }
export type MockDataStoreListingPages = setmetatable<RawMockDataStoreListingPages, { __index: typeof(class_scope) }>

local function new(
	data_pages: { { data_store_info.MockDataStoreInfo } },
	cursor_offset: number
): MockDataStoreListingPages
	local obj = setmetatable(pages.new_raw(data_pages), { __index = class_scope }) :: any
	obj.Cursor = "1"
	obj.AdvanceToNextPageAsync = function(self: MockDataStoreListingPages)
		pages.class_scope.AdvanceToNextPageAsync(self)
		self.Cursor = tostring(self._idx + cursor_offset - 1)
	end
	return obj
end

class_scope.ClassName = "DataStoreListingPages"

mod.class_scope = class_scope
mod.new = new

return mod
