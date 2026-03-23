--!optimize 2
-- https://create.roblox.com/docs/reference/engine/classes/Pages

local instance = require("./Instance")

local mod = {}
local class_scope = setmetatable({}, { __index = instance.class_scope })

export type RawMockPages<V = any> = {
	IsFinished: boolean,
	_pages: { { V } },
	_idx: number,
}
export type MockPages<V = any> = setmetatable<RawMockPages<V>, { __index: typeof(class_scope) }>

local function advance_to_next_page_async<K, V>(self: RawMockPages<V>)
	if self.IsFinished then return end
	self._idx += 1
	if self._idx == #self._pages then self.IsFinished = true end
end

local function get_current_page<V>(self: RawMockPages<V>): { V }
	return self._pages[self._idx] or {}
end

local function new_raw<V>(pages: { { V } }): RawMockPages<V>
	return {
		IsFinished = #pages == 0,
		_idx = 1,
		_pages = pages,
	}
end

class_scope.AdvanceToNextPageAsync = advance_to_next_page_async
class_scope.GetCurrentPage = get_current_page
class_scope.ClassName = "Pages"

mod.class_scope = class_scope
mod.new_raw = new_raw

return mod
