--!optimize 2

local pages = require("./Pages")

--- https://create.roblox.com/docs/reference/engine/classes/DataStorePages
local mod = {}
local class_scope = setmetatable({}, { __index = pages.class_scope })

export type RawMockDataStorePages = pages.RawMockPages<{ key: string, value: number }>
export type MockDataStorePages = setmetatable<RawMockDataStorePages, { __index: typeof(class_scope) }>

local function new(data_pages: { { { key: string, value: number } } }): MockDataStorePages
	return setmetatable(pages.new_raw(data_pages), { __index = class_scope })
end

class_scope.ClassName = "DataStorePages"

mod.class_scope = class_scope
mod.new = new

return mod
