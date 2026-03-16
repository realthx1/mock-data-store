--!optimize 2

local mod = {}
local class_scope = {}

export type RawMockInstance = {}
export type MockInstance = setmetatable<RawMockInstance, { __index: typeof(class_scope) }>

local function is_a(self: any, class: string): boolean
	return self.ClassName == class
end

class_scope.IsA = is_a

mod.class_scope = class_scope

return mod
