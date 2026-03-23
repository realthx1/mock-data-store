--!optimize 2

local pages = require("./Pages")
local data_store_key = require("./DataStoreKey")

--- https://create.roblox.com/docs/reference/engine/classes/DataStorePages
local mod = {}
local class_scope = setmetatable({}, { __index = pages.class_scope })

export type RawMockDataStoreKeyPages = pages.RawMockPages<data_store_key.MockDataStoreKey> & { Cursor: string }
export type MockDataStoreKeyPages = setmetatable<RawMockDataStoreKeyPages, { __index: typeof(class_scope) }>

local function new(data_pages: { { data_store_key.MockDataStoreKey } }, cursor_offset: number): MockDataStoreKeyPages
	local obj = setmetatable(pages.new_raw(data_pages), { __index = class_scope }) :: any
	obj.Cursor = tostring(cursor_offset)
	obj.AdvanceToNextPageAsync = function(self: MockDataStoreKeyPages)
		pages.class_scope.AdvanceToNextPageAsync(self)
		self.Cursor = tostring(self._idx + cursor_offset - 1)
	end
	return obj
end

class_scope.ClassName = "DataStoreKeyPages"

mod.class_scope = class_scope
mod.new = new

return mod
